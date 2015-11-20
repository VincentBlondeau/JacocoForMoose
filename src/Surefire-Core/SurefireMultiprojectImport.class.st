Class {
	#name : #SurefireMultiprojectImport,
	#superclass : #SurefireImport,
	#category : #'Surefire-Core'
}

{ #category : #'as yet unclassified' }
SurefireMultiprojectImport >> testsResultsFiles [
	| folders |
	folders := SurefireFileRetriever runOn: self rootFolder.
	^ (folders flatCollect: [ :folder | folder reference files ])
		select: [ :f | f extension = 'xml' ]
]
