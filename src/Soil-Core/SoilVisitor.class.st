Class {
	#name : #SoilVisitor,
	#superclass : #Object,
	#category : #'Soil-Core-Visitor'
}

{ #category : #testing }
SoilVisitor class >> isAbstract [
	<ignoreForCoverage>
	^ self == SoilVisitor
]

{ #category : #visiting }
SoilVisitor >> processReference: reference [
	self visit: reference
]

{ #category : #visiting }
SoilVisitor >> visit: anObject [ 
	^ anObject acceptSoil: self 
	
]

{ #category : #visiting }
SoilVisitor >> visitAll: aCollection [ 
	^ aCollection collect: [ :each |
		self visit: each ]
]

{ #category : #visiting }
SoilVisitor >> visitControl: aSoilControlFile [ 

]

{ #category : #visiting }
SoilVisitor >> visitDatabaseJournal: aSoilJournal [ 
	self visitAll: aSoilJournal fragmentFiles.
	^ aSoilJournal 
]

{ #category : #visiting }
SoilVisitor >> visitIndexManager: aSoilIndexManager [ 
	^ aSoilIndexManager 
]

{ #category : #visiting }
SoilVisitor >> visitJournalFragmentFile: aSoilJournalFragmentFile [ 
	aSoilJournalFragmentFile open.
	[ self visitAll: aSoilJournalFragmentFile transactionJournals ]
		ensure: [ aSoilJournalFragmentFile close ].
	^ aSoilJournalFragmentFile 
]

{ #category : #visiting }
SoilVisitor >> visitMetaSegment: aSoilMetaSegment [ 
	self visit: aSoilMetaSegment indexManager.
	^ aSoilMetaSegment 
]

{ #category : #visiting }
SoilVisitor >> visitObjectId: aSoilObjectId [ 
	^ aSoilObjectId 
]

{ #category : #visiting }
SoilVisitor >> visitObjectRepository: aSoilObjectRepository [ 
	self visitAll: aSoilObjectRepository allSegments.
	^ aSoilObjectRepository 
]

{ #category : #visiting }
SoilVisitor >> visitObjectSegment: aSoilObjectSegment [ 
	(aSoilObjectSegment id = 1) ifTrue: [ 
		self visit: (aSoilObjectSegment at: 1) ].
	self visit: aSoilObjectSegment indexManager.

	^ aSoilObjectSegment 
]

{ #category : #visiting }
SoilVisitor >> visitPagedFileIndexStore: aSoilPagedFileIndexStore [ 
	
]

{ #category : #visiting }
SoilVisitor >> visitPersistentClusterVersion: aSoilPersistentClusterVersion [ 
	aSoilPersistentClusterVersion references 
		do: [ :reference | self processReference: reference ].
	^ aSoilPersistentClusterVersion 
]

{ #category : #visiting }
SoilVisitor >> visitSkipList: aSoilSkipList [ 
	self visit: aSoilSkipList store
]

{ #category : #visiting }
SoilVisitor >> visitSoil: aSoil [ 
	self visit: aSoil control.
	self visit: aSoil objectRepository.
	self visit: aSoil journal.
	^ aSoil
]

{ #category : #visiting }
SoilVisitor >> visitTransactionJournal: aSoilTransactionJournal [ 
	^ aSoilTransactionJournal 
]
