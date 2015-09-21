"
The maven surefire parser of test results
"
Class {
	#name : #SurefireSaxParser,
	#superclass : #SAXHandler,
	#instVars : [
		'result',
		'testCase',
		'testSuite'
	],
	#category : #'Surefire-Core'
}

{ #category : #'handling - content' }
SurefireSaxParser >> endElement: aQualifiedName [
	aQualifiedName = 'testsuite'
		ifTrue: [ testSuite := nil.
			testCase := nil ].
	aQualifiedName = 'testcase'
		ifTrue: [ result add: testCase ].

]

{ #category : #parsing }
SurefireSaxParser >> parsingResult [
	^ result
]

{ #category : #converter }
SurefireSaxParser >> reduceData: aDictionary withScheme: aScheme [
	| value |
	^ ((aScheme
		pairsCollect:
			[ :entry :key | 
			value := [ (aDictionary at: key) asNumber ]
				on: Error
				do: [ :ex | 
					ex messageText = 'Reading a number failed: a digit between 0 and 9 expected'
						ifTrue: [ aDictionary at: key ifAbsent: [ nil ] ]
						ifFalse: [ ex resume ] ].
			value ifNotNil: [ entry -> value ] ]) select: #isNotNil) asDictionary
]

{ #category : #'handling - content' }
SurefireSaxParser >> startDocument [
	result := OrderedCollection new
]

{ #category : #'handling - content' }
SurefireSaxParser >> startElement: aQualifiedName attributes: aDictionary [
	| status |
	aQualifiedName = 'testsuite'
		ifTrue:
			[ testSuite := self
				reduceData: aDictionary
				withScheme: #(#name #name #incomplete #incomplete) ].
	aQualifiedName = 'testcase'
		ifTrue:
			[ testCase := self
				reduceData: aDictionary
				withScheme:
					#(#time #time #testSuiteName #classname #testCaseName #name  #skipped #ignored).
			status := testSuite
				at: #incomplete
				ifPresent: [ testSuite at: #status ]
				ifAbsent:
					[ testCase at: #skipped ifPresent: [ 'skipped' ] ifAbsent: [ 'pass' ] ].
			testCase at: #status put: status ].
	(#('error' 'skipped' 'failure') includes: aQualifiedName)
		ifTrue:
			[ testCase
				ifNotNil: [ testCase at: #status put: aQualifiedName ]
				ifNil:
					[ self assert: (testSuite at: #incomplete) = 'true'.
					testSuite at: #status put: aQualifiedName ] ]
]
