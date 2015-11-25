"
The maven surefire parser of test results
"
Class {
	#name : #SurefireImport,
	#superclass : #MooseFileOperator,
	#category : #'Surefire-Core'
}

{ #category : #private }
SurefireImport >> basicRun [
	| testSuiteFiles |
	testSuiteFiles := self testsResultsFiles.
	testSuiteFiles do: [ :aFile | self importTestSuite: aFile ]
]

{ #category : #importing }
SurefireImport >> importTestCase: aTestCaseResult [
	| mooseClassName methodOrClass |
	mooseClassName := (aTestCaseResult at: #testSuiteName) copyReplaceAll: '.' with: '::'.
	(self isException: mooseClassName)
		ifTrue: [ ^ self ].
	methodOrClass := self model
		javaEntityNamed:
			((aTestCaseResult at: #testSuiteName) = (aTestCaseResult at: #testCaseName)
				ifTrue: [ mooseClassName ]
				ifFalse: [ mooseClassName , '.' , (aTestCaseResult at: #testCaseName) , '()' ]).
	methodOrClass
		ifNil:
			[ {'[Surefire] Search in superclass '. (aTestCaseResult at: #testCaseName) . mooseClassName } asLog emit.
			methodOrClass := self
				searchMethodNamed: (aTestCaseResult at: #testCaseName) , '()'
				inSuperclassesOf: (self model javaEntityNamed: mooseClassName) ].	"Because it should be an abstract test class"
	methodOrClass testRunningTime: (aTestCaseResult at: #time ifAbsent: [ 0 ]).
	methodOrClass testStatus: (aTestCaseResult at: #status)
]

{ #category : #importing }
SurefireImport >> importTestSuite: aFileReference [
	| parsingResult |
	[ parsingResult := SurefireSaxParser parse: aFileReference contents.
	parsingResult do: [ :aRes | self importTestCase: aRes ] ]
		on: FileDoesNotExist
		do: [ :ex | ex asLog emit ]
	"Actually, it is because the path is too long..."
]

{ #category : #'as yet unclassified' }
SurefireImport >> isException: aString [ 
	^ aString =  'TempTest'
]

{ #category : #'as yet unclassified' }
SurefireImport >> searchMethodNamed: aMethodName inSuperclassesOf: aFAMIXClass [
	| methods |
	methods := aFAMIXClass superclassHierarchy
		flatCollect: [ :c | c methods select: [ :m | m signature = aMethodName ] ].
	self assert: methods size = 1.
	^ methods first
]

{ #category : #private }
SurefireImport >> testsResultsFiles [
	^ self rootFolder children select: [ :f | f extension = 'xml' ]
]
