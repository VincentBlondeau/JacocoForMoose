Class {
	#name : #InfinitestImport,
	#superclass : #MooseFileOperator,
	#instVars : [
		'testClass'
	],
	#category : #'Infinitest-Core'
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
		ifAbsent:
			[ outerCandidateClass := model
				entityNamed: (change substrings: '$') first
				ifAbsent:
					[ | items |
					items := (change substrings: '$') first substrings: '::'.
					((items last = 'package-info' or: [ items first = 'WEB-INF' ])
						or:
							[ items size = 1	"should be resolved because this class is in the default package" ])
						ifTrue: [ Log warn: {'[Infinitest] No class found T'. change}.^ ResumableNotFound signalFor: change ]
						ifFalse: [ Log warn: {'[Infinitest] No class found F'. change}. ^ ResumableNotFound signalFor: change ] ].
			candidateClass := outerCandidateClass methods
				collect: #innerClassesImplementingMethods
				thenSelect: #isNotEmpty.
			candidateClass flatten size = 1
				ifTrue: [ candidateClass flatten first ]
				ifFalse:
					[ model
						entityNamed: ('::' join: (change substrings: '$'))
						ifAbsent:
							[ candidateClass flatten	"at: (change substrings: '$') second asNumber" ]
					"We don't know how to solve it... -> choose one, all or none?" ] ].
	mooseCoveredTests := anAssociation value
		collect: [ :e | model entityNamed: e ].
	changedEntity asOrderedCollection
		do:
			[ :e | 
			e isConsideredAsChangedByInfinitest: true.
			e coveredByInfinitestTests: (mooseCoveredTests copyWithout: nil) ]
]

{ #category : #accessing }
InfinitestImport >> infinitestResultsFile [
	| files |
	files := (self rootFolder ifNil: [ 'artifacts/infinitestExport' ]) asFileReference children.
	self assert: files size = 1.
	^ files first
]

{ #category : #parsing }
InfinitestImport >> parseFile: aFileReference [ 
	^ InfinitestResolver parse: aFileReference contents
]
