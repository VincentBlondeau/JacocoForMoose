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
	self assert: (status occurrencesOf: 'pass') equals: 1.
	self assert: (status occurrencesOf: 'error') equals: 1.
	self assert: (status occurrencesOf: 'failure') equals: 1.
	self assert: (status occurrencesOf: 'skipped') equals: 1.
	self assert: (result allSatisfy: [ :e | (e at: #time) = 1.1 ]).
	self
		assert:
			(result
				allSatisfy:
					[ :e | (e at: #testCaseName) beginsWith: 'testCompleteTechnologyModel' ])
]

{ #category : #'as yet unclassified' }
SurefireParserTest >> testSurefireXmlParsing2 [
	| result status |
	result := SurefireSaxParser parse: self xmlResource2.
	self assert: result size equals: 8.
	status := result collect: [ :e | e at: #status ].
	self assert: (status occurrencesOf: 'pass') equals: 1.
	self assert:  (status occurrencesOf: 'error') equals: 5.
	self assert:  (status occurrencesOf: 'failure') equals: 1.
	self assert:  (status occurrencesOf: 'skipped') equals: 1.
	
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

{ #category : #'as yet unclassified' }
SurefireParserTest >> xmlResource2 [
	^ '<?xml version="1.0" encoding="UTF-8"?>
  <testrun name="aa.test.globalTest with jacoco" project="aa.test.globalTest" tests="8" started="5" failures="1" errors="2" ignored="1">
  <testsuite name="aa.test.globalTest" incomplete="true">
    <error>java.lang.IllegalArgumentException: javax.naming.NameNotFoundException: Name "globalTest" not found.
	</error>
    <testcase name="testSimple" classname="aa.test.globalTest" incomplete="true"/>
    <testcase name="testException" classname="aa.test.globalTest" incomplete="true"/>
    <testcase name="testRestriction" classname="aa.test.globalTest" incomplete="true"/>
  </testsuite>
  <testsuite name="aa.test.testSecond" time="15.677">
    <testcase name="testSecond" classname="aa.test.testSecond" time="15.677">
      <failure>java.lang.AssertionError: javax.naming.NameNotFoundException</failure>
    </testcase>
  </testsuite>
  <testsuite name="aa.test.ReplacementTest" time="0.001">
    <testcase name="initializationError" classname="aa.test.ReplacementTest" time="0.001">
      <error>java.lang.Exception: No runnable methods
	</error>
    </testcase>
  </testsuite>
  <testsuite name="aa.test.ProduceTest" time="1.829">
    <testcase name="testUpdateProduce" classname="aa.test.ReplacementTest" time="1.829">
      <error>java.lang.IllegalArgumentException</error>
    </testcase>
  </testsuite>
   <testsuite name="aa.test.ProduceManageTest" time="0.0">
    <testcase name="testProducts" classname="aa.test.ProduceManageTest" time="0.0" ignored="true"/>
  </testsuite>
  <testsuite name="aa.test.ChargeTest" time="2.446">
    <testcase name="testCharge" classname="aa.test.ChargeTest" time="2.446"/>
  </testsuite>
</testrun>'
]
