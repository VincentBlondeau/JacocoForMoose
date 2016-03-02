Class {
	#name : #JacocoCommitImporter,
	#superclass : #MooseOperator,
	#category : #'Jacoco-TestSelection'
}

{ #category : #private }
JacocoCommitImporter >> basicRun [
	| dir |
	dir := (self argAt: #dir) asFileReference.
	dir children
		do:
			[ :aFileReference | 
			| commit linesAndFiles |
			linesAndFiles := self createModelFrom: aFileReference contents.
			commit := self model findCommitWithId: aFileReference basename.
			commit changes
				do:
					[ :aChange | 
					| lines famixEntitiesToRetrive |
					lines := linesAndFiles at: aChange file name asPath.
					famixEntitiesToRetrive := aChange linesChanged
						flatCollect:
							[ :aChangeInterval | self foundChangesMatches: aChangeInterval in: lines ]
						as: Set.
					aChange
						addModifiedEntities:
							(self
								retrieveFamixEntities: famixEntitiesToRetrive
								in: aChange file famixEntity).
					self halt ].
			self halt ].
	self halt
]

{ #category : #'as yet unclassified' }
JacocoCommitImporter >> createModelFrom: aString [
	| lines dico |
	lines := aString substrings: String crlf.
	dico := Dictionary new.
	lines
		do:
			[ :aLine | 
			| col fileEntry |
			col := aLine substrings: ';'.
			fileEntry := dico at: ('/', col first) asPath ifAbsentPut: [ Dictionary new ].
			fileEntry
				at: (col fifth asNumber to: col sixth asNumber)
				put:
					{(#type -> col second).
					(#file -> col first).
					(#itemName -> col fourth).
					(#package -> col third)} asDictionary ].
	^ dico
]

{ #category : #private }
JacocoCommitImporter >> foundChangesMatches: aChangeInterval in: lines [
	| numberOfLineModified currentLineOffset interval splittedLineOffset absolute  |
	currentLineOffset := (aChangeInterval substrings: ' ') second.
	splittedLineOffset := currentLineOffset substrings: ','.
	numberOfLineModified := splittedLineOffset size = 2
		ifTrue: [ splittedLineOffset second asSignedInteger = 0
				ifTrue: [ ^ nil	"dans ce cas les lignes ont ete supprimees " ]
				ifFalse: [ splittedLineOffset second asSignedInteger ] ]
		ifFalse: [ 0 ].
	absolute := splittedLineOffset first asSignedInteger.
	interval := absolute to: absolute + numberOfLineModified.
	^ (lines associationsSelect: [ :e | (e key intersection: interval) isNotEmpty ]) values
]

{ #category : #'as yet unclassified' }
JacocoCommitImporter >> retrieveFamixEntities: aCollection in: aFAMIXClass [ 
	aCollection do: [ :entityToFind | 
		entityToFind halt
		 ].
	self shouldBeImplemented.
]
