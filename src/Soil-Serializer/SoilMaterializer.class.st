Class {
	#name : #SoilMaterializer,
	#superclass : #SoilBasicMaterializer,
	#category : #'Soil-Serializer-Serializer/Materializer'
}

{ #category : #materializing }
SoilMaterializer class >> materializeFromBytes: aByteArray [
	^ (self on: aByteArray readStream)
		materialize
]

{ #category : #'reading - basic' }
SoilMaterializer class >> nextLengthEncodedInteger [

	| value aSoilMaterializer |
	self flag: #TODO. "seems to be not called and does not work"
	aSoilMaterializer := self new.
	value := aSoilMaterializer nextByte.
	value < 128 ifTrue: [ ^ value ].
	^ (aSoilMaterializer nextLengthEncodedInteger bitShift: 7) bitOr:
		  (value bitAnd: 127)
]

{ #category : #'instance creation' }
SoilMaterializer class >> on: aReadStream [
	^ self new 
		stream: aReadStream 
]

{ #category : #public }
SoilMaterializer >> behaviorVersionsUpTo: aDescription [ 
	^ transaction behaviorVersionsUpTo: aDescription 
]

{ #category : #accessing }
SoilMaterializer >> indexAt: indexId [ 
	^ externalObjectRegistry indexAt: indexId
]

{ #category : #public }
SoilMaterializer >> materialize [
	^ self nextSoilObject
]

{ #category : #public }
SoilMaterializer >> materializeFromBytes: aByteArray [
	^ (self stream: aByteArray readStream)
		materialize
]

{ #category : #'instance creation' }
SoilMaterializer >> newObject [

	^ self nextBehaviorDescription newObjectWith: self
]

{ #category : #reading }
SoilMaterializer >> nextArray: aClass [ 
	| array |
	array := aClass new: self nextLengthEncodedInteger.
	self registerObject: array.
	1 to: array size do: [ :index | array at: index put: self nextSoilObject ].
	^ array
]

{ #category : #reading }
SoilMaterializer >> nextAssociation: aClass [ 
	| association |
	association := aClass new.
	self registerObject: association.
	^ association
		key: self nextSoilObject;
		value: self nextSoilObject
]

{ #category : #reading }
SoilMaterializer >> nextBehaviorDescription [
	| behaviorIndex behaviorDescription |
	behaviorIndex := self nextLengthEncodedInteger.
	(behaviorIndex = 0) ifTrue: [ ^ SoilBehaviorDescription meta ].
	behaviorDescription := externalObjectRegistry 
				behaviorDescriptionAt: behaviorIndex.
	^ externalObjectRegistry 
		behaviorDescriptionWithObjectId: behaviorDescription objectId 
		andVersion: behaviorDescription version
]

{ #category : #reading }
SoilMaterializer >> nextClass [
	^ Smalltalk 
		at: self basicNextString asSymbol 
		ifAbsent: nil
]

{ #category : #reading }
SoilMaterializer >> nextCompiledBlock11: aClass [

 	| header bytecodesSize compiledBlock |

 	header := self nextSoilObject.
 	bytecodesSize := self nextLengthEncodedInteger.
	
 	compiledBlock := aClass
 		newMethod: bytecodesSize
 		header: header.
	
	self registerObject: compiledBlock.

 	"first the literals
 	note: we omit the outer code here as we store clean blocks"
 	1 to: compiledBlock numLiterals - 1 do: [:i | 
 				compiledBlock literalAt: i put: self nextSoilObject ].			

 	compiledBlock initialPC 
 		to: compiledBlock size
 		do: [ :index |
 			compiledBlock
 				at: index
 				put: self nextByte ].

 	^compiledBlock
]

{ #category : #reading }
SoilMaterializer >> nextCompiledBlock12: aClass [

	| header bytecodesSize compiledBlock |
	header := self nextSoilObject.
	bytecodesSize := self nextLengthEncodedInteger.

	compiledBlock := aClass basicNew: bytecodesSize header: header.

	self registerObject: compiledBlock.

	"first the literals
 	note: we omit the outer code here as we store clean blocks"
	1 to: compiledBlock numLiterals - 1 do: [ :i |
	compiledBlock literalAt: i put: self nextSoilObject ].

	compiledBlock initialPC to: compiledBlock size do: [ :index |
	compiledBlock at: index put: self nextByte ].

	^ compiledBlock
]

{ #category : #reading }
SoilMaterializer >> nextCompiledBlock: aClass [
	"API changed from version 12 on"
 	^ SystemVersion current major < 12
		ifTrue: [self nextCompiledBlock11: aClass]
		ifFalse: [self nextCompiledBlock12: aClass]
]

{ #category : #reading }
SoilMaterializer >> nextCompiledMethod11: aClass [

 	| header bytecodesPlusTrailerSize compiledMethod |

 	header :=  self nextSoilObject.
 	bytecodesPlusTrailerSize := self nextLengthEncodedInteger.

 	compiledMethod := aClass
 		newMethod: bytecodesPlusTrailerSize
 		header: header.

	self registerObject: compiledMethod.

 	"first the literals"	
 	"for now we do store the class pointer in the last literal"	
 	1 to: compiledMethod numLiterals do: [:i | 
 				compiledMethod literalAt: i  put: self nextSoilObject ].			

 	"then the bytecodes, we ignore the trailer for now"
 	compiledMethod initialPC 
 		to: compiledMethod size - compiledMethod trailer size
 		do: [ :index |
 			compiledMethod
 				at: index
 				put: self nextByte ].
	
 	^compiledMethod
]

{ #category : #reading }
SoilMaterializer >> nextCompiledMethod12: aClass [

	| header bytecodesPlusTrailerSize compiledMethod |
	header := self nextSoilObject.
	bytecodesPlusTrailerSize := self nextLengthEncodedInteger.

	compiledMethod := aClass
		                  basicNew: bytecodesPlusTrailerSize
		                  header: header.

	self registerObject: compiledMethod.

	"first the literals"
	"for now we do store the class pointer in the last literal"
	1 to: compiledMethod numLiterals do: [ :i |
	compiledMethod literalAt: i put: self nextSoilObject ].

	"then the bytecodes, we ignore the trailer for now"
	compiledMethod initialPC 
		to: compiledMethod size - CompiledMethod trailerSize 
		do: [ :index | compiledMethod at: index put: self nextByte ].

	^ compiledMethod
]

{ #category : #reading }
SoilMaterializer >> nextCompiledMethod: aClass [

 	"API changed from version 12 on"
 	^ SystemVersion current major < 12
		ifTrue: [self nextCompiledMethod11: aClass]
		ifFalse: [self nextCompiledMethod12: aClass]
]

{ #category : #reading }
SoilMaterializer >> nextDictionary: aClass [ 
	| size dict key |
	size := self nextLengthEncodedInteger.
	dict := aClass new: size.
	self registerObject: dict.
	size timesRepeat: [
		key := self nextSoilObject.
		dict at: key put: self nextSoilObject.
	].
	^dict
]

{ #category : #reading }
SoilMaterializer >> nextExternalReference [
	| index |
	index := self nextLengthEncodedInteger.
	^ transaction proxyForObjectId: (externalObjectRegistry referenceAt: index) 
]

{ #category : #reading }
SoilMaterializer >> nextInternalReference [
	| index |
	index := self nextLengthEncodedInteger.
	^ objects at: index
]

{ #category : #reading }
SoilMaterializer >> nextOrderedCollection: aClass [ 
		| size collection |
	size := self  nextLengthEncodedInteger.
	collection := aClass new: size.
	self registerObject: collection.
	size timesRepeat: [ collection addLast: self nextSoilObject ].
	^ collection
]

{ #category : #reading }
SoilMaterializer >> nextPersistentDictionary: aClass [ 
	| size dict key |
	size := self nextLengthEncodedInteger.
	dict := aClass new: size.
	self registerObject: dict.
	size timesRepeat: [
		key := self nextSoilObject.
		dict at: key put: self nextSoilObject.
	].
	^dict
]

{ #category : #reading }
SoilMaterializer >> nextUUID: aClass [ 
	| uuid size byteArray |
	size := self nextLengthEncodedInteger.
	byteArray := SystemVersion current major < 12 
		ifTrue: [ aClass new: size] 
		ifFalse: [ ByteArray new: size].
	
	
	stream readInto: byteArray startingAt: 1 count: size.
	
	uuid := SystemVersion current major < 12 
		ifTrue: [byteArray ] 
		ifFalse: [UUID nilUUID uuidData: byteArray].
	
	self registerObject: uuid.
	
	^ uuid
]

{ #category : #registry }
SoilMaterializer >> registerObject: anObject [
	soil ifNotNil: [  
		soil notificationHandler objectMaterialized: anObject ].
	objects add: anObject 
]

{ #category : #accessing }
SoilMaterializer >> stream [
	^stream
]
