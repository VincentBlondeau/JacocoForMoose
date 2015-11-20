Class {
	#name : #SurefireMultiprojectImport,
	#superclass : #SurefireImport,
	#category : #'Surefire-Core'
}

{ #category : #'as yet unclassified' }
SurefireMultiprojectImport >> searchMethodNamed: aMethodName inSuperclassesOf: aFAMIXClass [
	| methods |
	methods := aFAMIXClass superclassHierarchy
		flatCollect: [ :c | c methods select: [ :m | m signature = aMethodName ] ].
	self assert: methods size = 1.
	^ methods first
]

{ #category : #'as yet unclassified' }
SurefireMultiprojectImport >> testsResultsFiles [
	| folders |
	folders := SurefireFileRetriever runOn: self rootFolder.
	^ (folders flatCollect: [ :folder | folder reference files ])
		select: [ :f | f extension = 'xml' ]
]
