Class {
	#name : #InfinitestImport,
	#superclass : #MooseOperator,
	#instVars : [
		'testClass'
	],
	#category : #'Jacoco-Infinitest'
}

{ #category : #'as yet unclassified' }
InfinitestImport >> basicRun [
	| tests |
	tests := self parseFile: self infinitestResultsFile.
	tests do: [ :association | [self importAssocInModel: association ] on: ResumableNotFound do: [ :ex | ex resume ]]
]

{ #category : #importing }
InfinitestImport >> importAssocInModel: anAssociation [
	| change changedEntity mooseCoveredTests candidateClass outerCandidateClass |
	"package.class$1 -> anonymous inner class"
	"package.class$innerClass -> named innerclass"
	"package.class$innerClass$innerInnerClass -> named innerclass"
	change := anAssociation key.
	changedEntity := model
		entityNamed: change
		ifAbsent: [ 
			outerCandidateClass := model
				entityNamed: (change substrings: '$') first
				ifAbsent: [ 
					((change substrings: '$') first substrings: '::') last = 'package-info'
						ifTrue: [ ^ ResumableNotFound signalFor: change ]
						ifFalse: [ self halt ] ].
			candidateClass := outerCandidateClass methods collect: #innerClassesImplementingMethods thenSelect: #isNotEmpty.
			candidateClass flatten size = 1
				ifTrue: [ candidateClass flatten first ]
				ifFalse: [ 
					model
						entityNamed: ('::' join: (change substrings: '$'))
						ifAbsent: [ 
							self halt.
							candidateClass flatten at: (change substrings: '$') second asNumber ] ] ].
	changedEntity isConsideredAsChangedByInfinitest: true.
	mooseCoveredTests := anAssociation value collect: [ :e | model entityNamed: e ].
	changedEntity coveredByInfinitestTests: mooseCoveredTests
]

{ #category : #accessing }
InfinitestImport >> infinitestResultsFile [
	| files |
	files := 'artifacts/infinitestExport' asFileReference children.
	self assert: files size = 1.
	^ files first
]

{ #category : #parsing }
InfinitestImport >> parseFile: aFileReference [ 
	^ InfinitestResolver parse: aFileReference contents
]
