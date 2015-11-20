Class {
	#name : #JacocoMultiprojectImport,
	#superclass : #JacocoImport,
	#category : #'Jacoco-Importer'
}

{ #category : #'as yet unclassified' }
JacocoMultiprojectImport >> coverageXmlFiles [
	| folders |
	folders := JacocoCoverageFilesRetriever runOn: self rootFolder.
	^ folders flatCollect: [ :folder | folder reference files ]
]
