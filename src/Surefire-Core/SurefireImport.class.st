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
	testSuiteFiles := self rootFolder children
		select: [ :f | f extension = 'xml' ].
	testSuiteFiles do: [ :aFile | self importTestSuite: aFile ]
]

{ #category : #importing }
SurefireImport >> importTestCase: aTestCaseResult [
	| mooseName methodOrClass |
	mooseName := (aTestCaseResult at: #testSuiteName)
		copyReplaceAll: '.'
		with: '::'.
	(self isException: mooseName)
		ifTrue: [ ^ self ].
	methodOrClass := self model
		entityNamed:
			((aTestCaseResult at: #testSuiteName)
				= (aTestCaseResult at: #testCaseName)
				ifTrue: [ mooseName ]
				ifFalse:
					[ mooseName , '.' , (aTestCaseResult at: #testCaseName) , '()' ]).
	methodOrClass
		testRunningTime: (aTestCaseResult at: #time ifAbsent: [ 0 ]).
	methodOrClass testStatus: (aTestCaseResult at: #status)
]

{ #category : #importing }
SurefireImport >> importTestSuite: aFileReference [
	| parsingResult |
	parsingResult := SurefireSaxParser parse: aFileReference contents.
	parsingResult do: [:aRes | self importTestCase: aRes ].
	
]

{ #category : #'as yet unclassified' }
SurefireImport >> isException: aString [ 
	^ aString =  'TempTest'
]
