Class {
	#name : #SoilSkipListPage,
	#superclass : #Object,
	#instVars : [
		'index',
		'items',
		'registry',
		'dirty',
		'right',
		'level',
		'keySize',
		'valueSize',
		'size'
	],
	#classInstVars : [
		'random'
	],
	#category : #'Soil-Core-Index-SkipList'
}

{ #category : #accessing }
SoilSkipListPage class >> random [
	^ random ifNil: [ 
		random := Random seed: Time microsecondClockValue. ]
]

{ #category : #adding }
SoilSkipListPage >> addItem: anAssociation [ 
	items add: anAssociation.
	dirty := true
]

{ #category : #'as yet unclassified' }
SoilSkipListPage >> beFirstPage [
	index := 1.
	level := self skipList maxLevel.
	self initializeRight.
	items 
		add: ((SoilSkipListSentinel lower keySize: self skipList keySize) numericValue -> 0);
		add: ((SoilSkipListSentinel upper keySize: self skipList keySize) numericValue -> 0)
]

{ #category : #'as yet unclassified' }
SoilSkipListPage >> biggestKey [
	^ items last key
]

{ #category : #accessing }
SoilSkipListPage >> firstItem [
	| item |
	item := items first.
	^ (item key = 0)
		ifTrue: [ items second ]
		ifFalse: [ item  ]
	
]

{ #category : #testing }
SoilSkipListPage >> hasItems [
	self flag: #todo.
	"need to filter lowest and highest key and check for zero"
	^ items size > 2
]

{ #category : #testing }
SoilSkipListPage >> hasRoom [
	^ self headerSize + ((items size + 1) * (keySize + valueSize)) <= self pageSize
]

{ #category : #utilities }
SoilSkipListPage >> headerSize [
	^ self indexSize + 1 "level" + (level * self indexSize)
]

{ #category : #accessing }
SoilSkipListPage >> index [
	^ index
]

{ #category : #accessing }
SoilSkipListPage >> index: anInteger [ 
	index := anInteger
]

{ #category : #accessing }
SoilSkipListPage >> indexOfKey: anInteger [ 
	items withIndexDo: [ :each :idx |
		(each key = anInteger) ifTrue: [ ^ idx ] ].
	^ 0
	
		
]

{ #category : #writing }
SoilSkipListPage >> indexSize [
	^ 2
]

{ #category : #initialization }
SoilSkipListPage >> initialize [ 
	super initialize.
	items := SortedCollection new.
	dirty := true.

]

{ #category : #initialization }
SoilSkipListPage >> initializeLevel: maxLevel [
	| promote |
	level := 1.
	promote := true.
	[ (level < maxLevel) & (promote = true) ] whileTrue: [ 
		level := level + 1.
		promote := self class random next > 0.5 ].
	self initializeRight 
]

{ #category : #initialization }
SoilSkipListPage >> initializeRight [ 
	right := Array new: level withAll: 0.
]

{ #category : #testing }
SoilSkipListPage >> isDirty [
	^ dirty 
]

{ #category : #'as yet unclassified' }
SoilSkipListPage >> itemAfter: key [ 
	| i item |
	i := items findBinaryIndex: [ :each | key - each key] do: [ :e | e ] ifNone: [ ^ nil ] .
	(i = items size) ifTrue: [ ^ nil].
	item := items at: i + 1.
	(item key >= ((2 raisedTo: 64) - 1)) ifTrue: [ ^ nil ].
	^ item
]

{ #category : #accessing }
SoilSkipListPage >> itemAt: anInteger put: anObject [ 
	items 
		findBinaryIndex: [ :each |  anInteger - each key ] 
		do: [:ind | items removeAt: ind ]
		ifNone: [ 0 ].
	items add: (anInteger -> anObject)
]

{ #category : #'as yet unclassified' }
SoilSkipListPage >> itemCapacity [
	^ ((self pageSize - self headerSize) / (self keySize + self valueSize)) floor
]

{ #category : #accessing }
SoilSkipListPage >> items [
	^ items
]

{ #category : #writing }
SoilSkipListPage >> itemsSizeSize [
	^ 2
]

{ #category : #accessing }
SoilSkipListPage >> keySize [ 
	^ keySize
]

{ #category : #accessing }
SoilSkipListPage >> keySize: anInteger [ 
	(anInteger = 0) ifTrue: [ Error signal: 'cannot use key size 0' ].
	keySize := anInteger 
]

{ #category : #accessing }
SoilSkipListPage >> lastItem [
	| item maxKey |
	maxKey := (2 raisedTo: (keySize * 8)) - 1. 
	item := items last.
	^ (item key = maxKey)
		ifTrue: [ items at: items size - 1 ]
		ifFalse: [ item ] 
	
]

{ #category : #accessing }
SoilSkipListPage >> level [
	^ level
]

{ #category : #accessing }
SoilSkipListPage >> level: anObject [

	level := anObject.
	self initializeRight 
]

{ #category : #accessing }
SoilSkipListPage >> numberOfItems [
	^ items size 
]

{ #category : #accessing }
SoilSkipListPage >> pageSize [
	^ size
]

{ #category : #printing }
SoilSkipListPage >> printOn: aStream [ 
	aStream << 'page : #' << index asString
]

{ #category : #writing }
SoilSkipListPage >> readFrom: aStream [ 
	| numberOfItems |
	dirty := false.
	index := (aStream next: self indexSize) asInteger.
	level := aStream next asInteger.
	right := Array new: level.
	1 to: level do: [ :n |
		right at: n put: (aStream next: self rightSize) asInteger ].
	numberOfItems := (aStream next: self itemsSizeSize) asInteger.
	items := SortedCollection new: numberOfItems.
	numberOfItems timesRepeat: [ 
		items add: ((aStream next: self keySize) asInteger -> (aStream next: self valueSize)) ]
]

{ #category : #accessing }
SoilSkipListPage >> registry: aSoilPageRegistry [ 
	registry := aSoilPageRegistry
]

{ #category : #accessing }
SoilSkipListPage >> right [
	^ right
]

{ #category : #accessing }
SoilSkipListPage >> rightAt: anInteger [ 
	(anInteger > level) ifTrue: [ ^ 0 ]. 
	^ self right at: anInteger 
]

{ #category : #accessing }
SoilSkipListPage >> rightAt: anInteger put: anObject [ 
	self right at: anInteger put: anObject
]

{ #category : #writing }
SoilSkipListPage >> rightSize [
	^ 4
]

{ #category : #accessing }
SoilSkipListPage >> setItems: aCollection [ 
	items := aCollection
]

{ #category : #accessing }
SoilSkipListPage >> setRight: aCollection [ 
	right := aCollection 
]

{ #category : #accessing }
SoilSkipListPage >> size: anInteger [ 
	size := anInteger 
]

{ #category : #accessin }
SoilSkipListPage >> skipList [
	^ registry skipList
]

{ #category : #'as yet unclassified' }
SoilSkipListPage >> smallestKey [
	^ items first key
]

{ #category : #'as yet unclassified' }
SoilSkipListPage >> split [
	| newPage middle |
	newPage := self skipList newPage.
	newPage 
		registry: registry.
	middle := (items size / 2) ceiling.
	newPage setItems: (items copyFrom: middle + 1 to: items size).
	items removeLast: items size - middle.
	^ newPage
	
]

{ #category : #accessing }
SoilSkipListPage >> valueAt: anInteger [ 
	^ items 
		detect: [:each | each key = anInteger ] 
		ifNone: [ nil ]
]

{ #category : #accessing }
SoilSkipListPage >> valueSize [ 
	^ valueSize
]

{ #category : #accessing }
SoilSkipListPage >> valueSize: anInteger [ 
	valueSize := anInteger 
]

{ #category : #writing }
SoilSkipListPage >> writeOn: aStream [ 
	aStream 
		nextPutAll: (index asByteArrayOfSize: self indexSize);
		nextPut: level.
	1 to: level do: [ :n |
		aStream nextPutAll: ((right at: n) asByteArrayOfSize: self rightSize) ].
	aStream
		nextPutAll: (items size asByteArrayOfSize: self itemsSizeSize).
	items do: [ :assoc |
		aStream 
			nextPutAll: (assoc key asByteArrayOfSize: self keySize);
			nextPutAll: (assoc value asByteArrayOfSize: self valueSize)].
	dirty := false.
]