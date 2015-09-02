Class {
	#name : #InfinitestParserTest,
	#superclass : #PPCompositeParserTest,
	#category : #'Infinitest-Tests'
}

{ #category : #accessing }
InfinitestParserTest >> parserClass [
	^ InfinitestParser
]

{ #category : #accessing }
InfinitestParserTest >> testDependencies [
	self
		parse:
			'	net.myproject.bootstrap.BootstrapLauncher,
	net.myproject.core.profilemanagement.technologyapplication.TechnologyAndApplicationModelManagerTestCase,
	net.myproject.core.configuration.ServiceSettingsTestCase,
	net.myproject.core.2424TestCase,
'
		rule: #javaDependencies
]

{ #category : #accessing }
InfinitestParserTest >> testDependency [
	self
		parse:
			'	net.myproject.core.configuration.ServiceSettingsTestCase,
'
		rule: #dependency
]

{ #category : #accessing }
InfinitestParserTest >> testParseAll [
	self
		parse:
			'./target/classes/net/myproject/core/algorithm/DefaultContractReferenceAlgorithm.class[
	net.myproject.core.configuration.CardServiceSettingsTestCase,
]
./target/classes/net/myproject/core/algorithm/DefaultEarliestExtractionDateCalculationAlgorithm.class[
	net.myproject.core.algorithm.DefaultEarliestExtractionDateCalculationAlgorithmTestCase,
]
./target/classes/net/myproject/core/algorithm/2424.class[
	net.myproject.bootstrap.BootstrapLauncher,
	net.myproject.core.profilemanagement.technologyapplication.TechnologyAndApplicationModelManagerTestCase,
	net.myproject.core.configuration.ServiceSettingsTestCase,
	net.myproject.core.2424TestCase,
]'
]
