Class {
	#name : #SoilPagedFileIndexStore,
	#superclass : #SoilPagedIndexStore,
	#instVars : [
		'stream',
		'streamSemaphore'
	],
	#category : #'Soil-Core-Index-SkipList'
}

{ #category : #queries }
SoilPagedFileIndexStore >> allItems [
	^ pagesMutex critical: [  
		pages flatCollect: #items ]
]

{ #category : #converting }
SoilPagedFileIndexStore >> asCopyOnWriteStore [
	^ SoilCopyOnWriteIndexStore new 
		wrappedStore: self
]

{ #category : #'initialize-release' }
SoilPagedFileIndexStore >> close [ 
	stream ifNotNil: [  
		stream close.
		stream := nil ]
]

{ #category : #'instance creation' }
SoilPagedFileIndexStore >> filePageSize [
	"most OSses use a file page size of 4k today"
	^ 4096
]

{ #category : #accessing }
SoilPagedFileIndexStore >> flush [
	self flushPages 
]

{ #category : #'as yet unclassified' }
SoilPagedFileIndexStore >> flushPages [
	pagesMutex critical: [  
		pages valuesDo: [ :page |
			page isDirty ifTrue: [ 
				self writePage: page ] ] ]
]

{ #category : #testing }
SoilPagedFileIndexStore >> hasStream [
	^ stream notNil
]

{ #category : #initialization }
SoilPagedFileIndexStore >> initialize [ 
	super initialize.
	streamSemaphore := Semaphore forMutualExclusion 
]

{ #category : #initialization }
SoilPagedFileIndexStore >> initializeFilesystem [
	self openStream
]

{ #category : #initialization }
SoilPagedFileIndexStore >> initializeHeaderPage [
	| page |
	page := index newHeaderPage.
	pagesMutex critical: [  
		pages at: page index put: page	]
]

{ #category : #'instance creation' }
SoilPagedFileIndexStore >> open [
	self 
		openStream;
		readHeaderPage 
]

{ #category : #opening }
SoilPagedFileIndexStore >> openStream [
	stream := SoilLockableStream path: index path.
]

{ #category : #accessing }
SoilPagedFileIndexStore >> pageFaultAt: anInteger [
	| page |
	streamSemaphore critical: [  
		stream position: (self positionOfPageIndex: anInteger).
		page := index newPage 
			readFrom: stream ].
	pagesMutex critical: [  
		pages at: anInteger put: page ].
	^ page
]

{ #category : #'as yet unclassified' }
SoilPagedFileIndexStore >> pagesStart [
	^ 4096
]

{ #category : #'instance creation' }
SoilPagedFileIndexStore >> positionOfPageIndex: anInteger [
	^ ((anInteger - 1) * self filePageSize)
]

{ #category : #'as yet unclassified' }
SoilPagedFileIndexStore >> readHeaderPage [
	| headerPage |
	streamSemaphore critical: [  
		stream position: 0.
		headerPage := index newHeaderPage readFrom: stream ].
	pagesMutex critical: [  
		pages at: 1 put: headerPage ]
]

{ #category : #accessing }
SoilPagedFileIndexStore >> replace: oldPage with: newPage [ 
	pagesMutex critical: [  
		pages
			at: oldPage index 
			put:newPage ]
]

{ #category : #accessing }
SoilPagedFileIndexStore >> stream [
	^ stream 
]

{ #category : #writing }
SoilPagedFileIndexStore >> writeHeaderPage [
	streamSemaphore critical: [  
		self stream position: 0.
		self headerPage writeOn: self stream ]
]

{ #category : #writing }
SoilPagedFileIndexStore >> writePage: aPage [ 
	| pagePosition |
	streamSemaphore critical: [  
		pagePosition := self positionOfPageIndex: aPage index.  
		stream position: pagePosition.
		aPage writeOn: stream.
		stream flush ]
]