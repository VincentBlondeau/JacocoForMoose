Class {
	#name : #JacocoCommitExporter,
	#superclass : #MooseOperator,
	#category : #'Jacoco-TestSelection'
}

{ #category : #'as yet unclassified' }
JacocoCommitExporter >> basicRun [
	self model allCommitsSortedByDate
		do:
			[ :commit | 
			| fileName filesToPrint |
			fileName := commit date asFileNameCompatibleString,'_', commit revision. 
			filesToPrint := commit allAddedOrChangedFiles
				select: [ :aChangeSet | aChangeSet file isJavaFile ].
			filesToPrint
				ifNotEmpty:
					[ | newFile stream |
					[ newFile := (self dataFolder /  fileName) ensureCreateFile.
					stream := newFile writeStream.
					filesToPrint
						do: [ :aFile | stream << aFile file name allButFirst ]
						separatedBy: [ stream crlf ] ]
						ensure: [ newFile ifNotNil: [ stream close ] ] ] ]
]

{ #category : #'as yet unclassified' }
JacocoCommitExporter >> dataFolder [
	^ (self argAt: #outDir) asFileReference / (self argAt: #project)
]

{ #category : #'as yet unclassified' }
JacocoCommitExporter >> setUp [
	self dataFolder ensureCreateDirectory
]
