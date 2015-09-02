Class {
	#name : #SurefireParserTest,
	#superclass : #TestCase,
	#category : #'Surefire-Tests'
}

{ #category : #'as yet unclassified' }
SurefireParserTest >> testSurefireXmlParsing [
	| result status |
	result := SurefireSaxParser parse: self xmlResource.
	self assert: result size equals: 4.
	status := result collect: [ :e | e at: #status ].
	self assert: (status includes: 'pass').
	self assert: (status includes: 'error').
	self assert: (status includes: 'failure').
	self assert: (result allSatisfy: [ :e | (e at: #time) = 1.1 ]).
	self
		assert:
			(result
				allSatisfy:
					[ :e | (e at: #testCaseName) beginsWith: 'testCompleteTechnologyModel' ])
]

{ #category : #'as yet unclassified' }
SurefireParserTest >> xmlResource [
	^ '<testsuite failures="1" time="4.400" errors="1" skipped="1" tests="4" name="myproject.application.ApplicationModelManagerTestCase">
	<properties>
		<property name="java.runtime.name" value="Java(TM) SE Runtime Environment" />
		<property name="sun.boot.library.path" value="/usr/java/jdk-1.7/jre/lib/amd64" />
		<property name="java.vm.vendor" value="Oracle Corporation" />
		<property name="java.vendor.url" value="http://java.oracle.com/" />
		<property name="path.separator" value=":" />
	</properties>
	<testcase time="1.100"
		classname="myproject.application.ApplicationModelManagerTestCase"
		name="testCompleteTechnologyModel31" />
	<testcase time="1.100"
		classname="myproject.application.ApplicationModelManagerTestCase"
		name="testCompleteTechnologyModel01">
		<failure
			message="System has performed updateNonVirtualCardTechnologyModel() operation, throwing an exception"
			type="java.lang.AssertionError">stack trace
		</failure>
		<system-out>[Surefire]</system-out>
	</testcase>
	<testcase time="1.100"
		classname="myproject.application.ApplicationModelManagerTestCase"
		name="testCompleteTechnologyModel17">
		<skipped />
	</testcase>
	<testcase time="1.100"
		classname="myproject.application.ApplicationModelManagerTestCase"
		name="testCompleteTechnologyModel15">
		<error message="Model does not exist"
			type="ConstraintViolatedException">stack trace 
		</error>
		<system-out>[Surefire]</system-out>
	</testcase>
</testsuite>'
]
