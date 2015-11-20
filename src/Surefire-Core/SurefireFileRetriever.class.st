Class {
	#name : #SurefireFileRetriever,
	#superclass : #MAMAbstractFilesRetriever,
	#category : #'Surefire-Core'
}

{ #category : #'as yet unclassified' }
SurefireFileRetriever >> excludedDirectories [
	^ #('.svn' 'src')
]

{ #category : #'as yet unclassified' }
SurefireFileRetriever >> fileName [
	^ 'surefire-reports'
]
