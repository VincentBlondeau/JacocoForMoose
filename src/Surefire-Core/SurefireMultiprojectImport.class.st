Class {
	#name : #SurefireMultiprojectImport,
	#superclass : #SurefireImport,
	#category : #'Surefire-Core'
}

{ #category : #'as yet unclassified' }
SurefireMultiprojectImport >> createMethodNamed: aMethodName inClass: aFAMIXClass [ 
	| methodToCopy |
	methodToCopy := self searchMethodNamed: aMethodName inSuperclassesOf: aFAMIXClass.
	methodToCopy copy.
self halt.
	aMethodName 
	aFAMIXClass find
]

{ #category : #'as yet unclassified' }
SurefireMultiprojectImport >> testsResultsFiles [
	| folders |
	folders := SurefireFileRetriever runOn: self rootFolder.
	^ (folders flatCollect: [ :folder | folder reference files ])
		select: [ :f | f extension = 'xml' ]
]
