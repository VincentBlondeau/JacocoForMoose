"
The maven surefire parser of test results
"
Class {
	#name : #SurefireSaxParser,
	#superclass : #SAXHandler,
	#instVars : [
		'result',
		'testCase'
	],
	#category : #'Surefire-Core'
}

{ #category : #'handling - content' }
SurefireSaxParser >> endElement: aQualifiedName [
	aQualifiedName = 'testcase'
		ifTrue: [ result add: testCase ]
]

{ #category : #parsing }
SurefireSaxParser >> parsingResult [
	^ result
]

{ #category : #converter }
SurefireSaxParser >> reduceData: aDictionary withScheme: aScheme [
	^ (aScheme
		pairsCollect:
			[ :entry :key | 
			entry
				->
					([ (aDictionary at: key) asNumber ]
						on: Error
						do:
							[ :ex | 
							ex messageText
								=
									'Reading a number failed: a digit between 0 and 9 expected'
								ifTrue: [ aDictionary at: key ]
								ifFalse: [ ex resume ] ]) ]) asDictionary
]

{ #category : #'handling - content' }
SurefireSaxParser >> startDocument [
	result := OrderedCollection new
]

{ #category : #'handling - content' }
SurefireSaxParser >> startElement: aQualifiedName attributes: aDictionary [
	"	aQualifiedName = 'testsuite'
		ifTrue:
			[ 
			testCaseProperties := self
				reduceData: aDictionary
				withScheme:
					#(#nbFailure #failures #time #time #nbErrors #errors #nbSkipped #skipped #nbTests #tests #testSuiteName #name) ]."

	aQualifiedName = 'testcase'
		ifTrue: [ 
			testCase := self reduceData: aDictionary withScheme: #(#time #time #testSuiteName classname #testCaseName #name ).
			testCase at: #status put: 'pass' ].
	(#('error' 'skipped' 'failure') includes: aQualifiedName)
		ifTrue: [ testCase at: #status put: aQualifiedName ]
]
