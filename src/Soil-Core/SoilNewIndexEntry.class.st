Class {
	#name : #SoilNewIndexEntry,
	#superclass : #SoilIndexJournalEntry,
	#instVars : [
		'keySize',
		'valueSize'
	],
	#category : #'Soil-Core-Journal'
}

{ #category : #accessing }
SoilNewIndexEntry >> keySize [

	^ keySize
]

{ #category : #accessing }
SoilNewIndexEntry >> keySize: anInteger [ 
	keySize := anInteger
]

{ #category : #accessing }
SoilNewIndexEntry >> valueSize [

	^ valueSize
]

{ #category : #accessing }
SoilNewIndexEntry >> valueSize: anInteger [ 
	valueSize := anInteger 
]