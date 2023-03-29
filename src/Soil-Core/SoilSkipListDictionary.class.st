Class {
	#name : #SoilSkipListDictionary,
	#superclass : #Object,
	#instVars : [
		'id',
		'transaction',
		'index',
		'newValues'
	],
	#category : #'Soil-Core'
}

{ #category : #accessing }
SoilSkipListDictionary class >> soilTransientInstVars [ 
	^ #( index transaction newValues )
]

{ #category : #accessing }
SoilSkipListDictionary >> at: key [ 
	| objectId |
	objectId := SOObjectId readFrom: (self index at: key) readStream.
	^ transaction proxyForObjectId: objectId
]

{ #category : #accessing }
SoilSkipListDictionary >> at: key put: anObject [
	transaction ifNotNil: [
		transaction makeRoot: anObject.
		transaction markDirty: self ].
	newValues at: key put: anObject
]

{ #category : #accessing }
SoilSkipListDictionary >> atIndex: anInteger [ 
	^ index atIndex: anInteger 
]

{ #category : #enumerating }
SoilSkipListDictionary >> do: aBlock [ 
	| objectId |
	self index do: [ :ba |
		objectId := SOObjectId readFrom: ba readStream.
		aBlock value: (transaction proxyForObjectId: objectId) ].
	newValues values do: [ :each | aBlock value: each ] 
]

{ #category : #accessing }
SoilSkipListDictionary >> first [
	self index path ifNotNil: [  
		^ self proxyFromByteArray: self index firstItem value ].
	^ newValues at: newValues keys sorted first
]

{ #category : #accessing }
SoilSkipListDictionary >> first: anInteger [ 
	^ (self index first: anInteger) collect: [ :each | self proxyFromByteArray: each ]  
]

{ #category : #accessing }
SoilSkipListDictionary >> id [
	^ id
]

{ #category : #accessing }
SoilSkipListDictionary >> index [
	^ index ifNil: [ 
		index := self lookupIndex ]
]

{ #category : #initialization }
SoilSkipListDictionary >> initialize [ 
	super initialize.
	newValues := Dictionary new.
	id := UUID new asString36.
	index := SoilSkipList new 
		valueSize: 8;
		yourself
]

{ #category : #testing }
SoilSkipListDictionary >> isEmpty [
	newValues ifNotEmpty: [ ^ false ].
	^ self index isEmpty
]

{ #category : #accessing }
SoilSkipListDictionary >> keySize: anInteger [ 
	index keySize: anInteger 
]

{ #category : #accessing }
SoilSkipListDictionary >> last [
	| objectId assoc |
	assoc := self index last.
	assoc ifNil: [ ^ nil ].
	objectId := SOObjectId readFrom: assoc value readStream.
	^ assoc key -> (transaction proxyForObjectId: objectId)
]

{ #category : #private }
SoilSkipListDictionary >> loadFrom: aFileReference [ 
	^ SoilSkipList new 
		path: aFileReference;
		open
]

{ #category : #'as yet unclassified' }
SoilSkipListDictionary >> lookupIndex [
	^ transaction lookupIndex: self
]

{ #category : #accessing }
SoilSkipListDictionary >> maxLevel: anInteger [ 
	index maxLevel: anInteger 
]

{ #category : #'as yet unclassified' }
SoilSkipListDictionary >> nextAfter: key [  
	| page |
	page := (self index iteratorForKey: key asInteger) page.
	^ page itemAfter: key asInteger.

]

{ #category : #printing }
SoilSkipListDictionary >> printOn: aStream [ 
	super printOn: aStream.
	aStream << ' id=' << id asString
]

{ #category : #enumerating }
SoilSkipListDictionary >> proxyFromByteArray: aByteArray [
	
	^ transaction proxyForObjectId: (SOObjectId readFrom: aByteArray readStream)
]

{ #category : #accessing }
SoilSkipListDictionary >> second [
	self index path ifNotNil: [  
		^ index iterator first; next ].
	^ newValues associations second
]

{ #category : #accessing }
SoilSkipListDictionary >> size [ 
	^ self index path 
		ifNotNil: [ self index size + newValues size ]
		ifNil: [ newValues size ] 
]

{ #category : #'as yet unclassified' }
SoilSkipListDictionary >> soilClusterRootIn: aTransaction [
	transaction ifNotNil: [ ^ self ].
	transaction := aTransaction.
	newValues ifNotEmpty: [
		newValues values do: [ :object |
			transaction makeRoot: object ].
		transaction markDirty: self]
]

{ #category : #'as yet unclassified' }
SoilSkipListDictionary >> soilLoadedIn: aTransaction [
	transaction := aTransaction.
	"when being materialized newValues is not initialized so we do it here"
	newValues := Dictionary new 
]

{ #category : #'as yet unclassified' }
SoilSkipListDictionary >> soilSerialize: aSerializer [ 
	| objectId |
	super soilSerialize: aSerializer.
	self index path ifNil: [  
		aSerializer registerIndexedObject: self ].
	newValues keysAndValuesDo: [ :key :object |
		objectId := transaction makeRoot: object.
		objectId initializeIndex: transaction objectRepository.
		index at: key put: objectId ].
	index writePages
]

{ #category : #accessing }
SoilSkipListDictionary >> values [
	| col |
	col := OrderedCollection new.
	self do: [ :each | col add: each ].
	^ col
]