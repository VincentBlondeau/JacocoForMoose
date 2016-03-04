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
			(commit changes
				select: [ :aChangeSet | aChangeSet file isJavaFile ])
				do: [ :aChange | self link: aChange with: linesAndFiles ] ]
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
			col := ';' split: aLine.
			fileEntry := dico
				at: ('/' , col first) asPath
				ifAbsentPut: [ Dictionary new ].
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
				ifTrue: [ ^ #()	"dans ce cas les lignes ont ete supprimees " ]
				ifFalse: [ splittedLineOffset second asSignedInteger ] ]
		ifFalse: [ 0 ].
	absolute := splittedLineOffset first asSignedInteger.
	interval := absolute to: absolute + numberOfLineModified.
	^ (lines associationsSelect: [ :e | (e key intersection: interval) isNotEmpty ]) values
]

{ #category : #private }
JacocoCommitImporter >> link: aChange with: linesAndFiles [
	| lines famixEntitiesToRetrive collOfFamixEntities |
	lines := linesAndFiles
		at: aChange file name asPath
		ifAbsent:
			[ Transcript logCr: 'FILE NOT FOUND!!! ' , aChange file name.
			^ nil ].
	famixEntitiesToRetrive := aChange linesChanged
		flatCollect:
			[ :aChangeInterval | self foundChangesMatches: aChangeInterval in: lines ]
		as: Set.
	collOfFamixEntities := self
		retrieveFamixEntities: famixEntitiesToRetrive
		in: aChange file famixEntity.
	(collOfFamixEntities isEmpty and: [ aChange file famixEntity isNil ])
		ifTrue: [ ^ nil ].
	^ aChange addAllModifiedEntities: collOfFamixEntities
]

{ #category : #'as yet unclassified' }
JacocoCommitImporter >> matchSignature: aSignatureWithChevron with: aSignatureWithoutChevron [
	| signature |
	aSignatureWithChevron = aSignatureWithoutChevron
		ifTrue: [ ^ true ].
	(aSignatureWithChevron includes: $<)
		ifFalse: [ ^ false ].
	signature := (aSignatureWithChevron copy copyWithRegex: '<[^>]*>' matchesReplacedWith: '')
		copyReplaceAll: '>'
		with: ''.
	^ signature = aSignatureWithoutChevron
]

{ #category : #'as yet unclassified' }
JacocoCommitImporter >> retrieveFamixEntity: entityToFind in: aFAMIXClass [
	| children name |
	"exceptions"
	aFAMIXClass ifNil: [ ^ self searchInModel: entityToFind ].
	"fast search"
	children := aFAMIXClass jacocoChildren
		add: aFAMIXClass;
		yourself.
	name := entityToFind at: #itemName.
	^ [ (entityToFind at: #type) = 'C'
		ifTrue:
			[ children detect: [ :e | e isClass and: [ e name = name ] ] ]
		ifFalse:
			[ children 
				detect:
					[ :e | e isMethod and: [ (e parentType name , '.' , e signature) = name ] ] ] ]
		on: NotFound
		do: [ self searchInModel: entityToFind ]	"less fast"
]

{ #category : #'as yet unclassified' }
JacocoCommitImporter >> searchInModel: aCollection [
	| package class candidatesClasses classOrMethod classOrMethodSubStrings |
	package := '::' join: ((aCollection at: #package) substrings: '.').
	classOrMethod := aCollection at: #itemName.
	classOrMethodSubStrings := classOrMethod substrings: '.'.
	classOrMethodSubStrings size > 2
		ifTrue: [ Transcript logCr: 'numberOfSubstrings>2:' ].
	class := classOrMethodSubStrings first.
	^ self model
		entityNamed: package , '::' , classOrMethod
		ifAbsent:
			[ self model
				entityNamed: package
				ifAbsent:
					[ candidatesClasses := self model allClasses
						select: [ :c | c name = class ].
					candidatesClasses ifEmpty: [ ^ nil ].
					candidatesClasses size = 1
						ifTrue: [ ^ candidatesClasses first ].
					^ nil]
				ifPresent:
					[ :e | 
					| method famixClass |
					famixClass := self model
						entityNamed: package , '::' , class
						ifAbsent: [ ^ nil ].
					(aCollection at: #type) = #C
						ifTrue: [ ^ class ].
					method := '.' join: classOrMethodSubStrings allButFirst.
					^ self searchMethod: method in: famixClass ].
			self halt ]
]

{ #category : #'as yet unclassified' }
JacocoCommitImporter >> searchMethod: aString in: aFAMIXClass [
	^ aFAMIXClass methods , aFAMIXClass innerMethods
		detect: [ :m | self matchSignature: m signature with: aString ]
		ifNone: [ Transcript logCr: 'Not found searchMethod:', aString, ' in ', aFAMIXClass printString.
			nil ]
]
