Class {
	#name : #SoilInstanceVisitor,
	#superclass : #SoilVisitor,
	#instVars : [
		'soil',
		'seen'
	],
	#category : #'Soil-Core-Model'
}

{ #category : #initialization }
SoilInstanceVisitor >> initialize [ 
	super initialize.
	seen := Set new.  
]

{ #category : #accessing }
SoilInstanceVisitor >> soil [

	^ soil
]

{ #category : #accessing }
SoilInstanceVisitor >> soil: anObject [

	soil := anObject
]

{ #category : #visiting }
SoilInstanceVisitor >> visitObjectId: aSoilObjectId [ 
	(seen includes: aSoilObjectId) ifTrue: [ ^ aSoilObjectId ].
	seen add: aSoilObjectId.
	self visit: (soil objectRepository at: aSoilObjectId).
	^ aSoilObjectId 
]

{ #category : #visiting }
SoilInstanceVisitor >> visitPagedFileIndexStore: aSoilPagedFileIndexStore [ 
	| numberOfPages |
	numberOfPages := aSoilPagedFileIndexStore headerPage lastPageIndex.
	1 to: numberOfPages do: [ :pageIndex | | page |
		page := aSoilPagedFileIndexStore pageAt: pageIndex.
		page items do: [ :item |
			item value isRemoved ifFalse: [ 
				self visit: item value ] ] ].
	^ aSoilPagedFileIndexStore 
]

{ #category : #visiting }
SoilInstanceVisitor >> visitPersistentClusterVersion: aSoilPersistentClusterVersion [ 
	super visitPersistentClusterVersion: aSoilPersistentClusterVersion.
	aSoilPersistentClusterVersion indexIds do:[ :indexId |
		self visit: ((soil objectRepository segmentAt: aSoilPersistentClusterVersion segment) indexAt: indexId)  ].
	^ aSoilPersistentClusterVersion 
]