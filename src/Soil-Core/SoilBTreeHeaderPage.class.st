"
The Header page is the first of the data pages. It knows the last page (and like all data pages the next page).

The header page is always there, even for an empty BTree.

It is easily accessible via #headerPage on the BTree index
"
Class {
	#name : #SoilBTreeHeaderPage,
	#superclass : #SoilAbstractBTreeDataPage,
	#instVars : [
		'lastPageIndex',
		'firstFreePageIndex'
	],
	#category : #'Soil-Core-Index-BTree'
}

{ #category : #accessing }
SoilBTreeHeaderPage class >> pageCode [ 
	^ 3
]

{ #category : #accessing }
SoilBTreeHeaderPage >> firstFreePageIndex: anObject [

	firstFreePageIndex := anObject
]

{ #category : #utilities }
SoilBTreeHeaderPage >> headerSize [
	^ super headerSize  
		+ 2 "valueSize"
		+ 2 "keySize"
		+ self pointerSize "lastPageIndex"
		+ self pointerSize "lastFreePageIndex"
]

{ #category : #initialization }
SoilBTreeHeaderPage >> initialize [ 
	super initialize.
	firstFreePageIndex := 0
]

{ #category : #initialization }
SoilBTreeHeaderPage >> initializeInIndex: aSoilSkipList [
]

{ #category : #testing }
SoilBTreeHeaderPage >> isHeaderPage [
	^ true
]

{ #category : #accessing }
SoilBTreeHeaderPage >> lastPageIndex [
	^ lastPageIndex
]

{ #category : #accessing }
SoilBTreeHeaderPage >> lastPageIndex: anObject [
	lastPageIndex := anObject.
	dirty := true
]

{ #category : #initialization }
SoilBTreeHeaderPage >> latestVersion [
	^ 1
]

{ #category : #accessing }
SoilBTreeHeaderPage >> nextPageIndex [
	lastPageIndex := lastPageIndex + 1.
	dirty := true.
	^ lastPageIndex 
]

{ #category : #printing }
SoilBTreeHeaderPage >> printOn: aStream [ 
	aStream << 'header page : #' << index asString
]

{ #category : #reading }
SoilBTreeHeaderPage >> readFrom: aStream [ 
	super readFrom: aStream.
	keySize := (aStream next: 2) asInteger.
	valueSize := (aStream next: 2) asInteger.
	lastPageIndex :=(aStream next: self pointerSize) asInteger.
	firstFreePageIndex :=(aStream next: 4) asInteger.
	self readItemsFrom: aStream
]

{ #category : #writing }
SoilBTreeHeaderPage >> writeHeaderOn: aStream [ 
	super writeHeaderOn: aStream.
	aStream
		nextPutAll: (keySize asByteArrayOfSize: 2);
		nextPutAll: (valueSize asByteArrayOfSize: 2);
		nextPutAll: (lastPageIndex asByteArrayOfSize: self pointerSize);
		nextPutAll: (firstFreePageIndex asByteArrayOfSize: 4)
]
