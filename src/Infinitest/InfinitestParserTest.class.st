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

{ #category : #accessing }
InfinitestParserTest >> testParseAllWindows [
	self
		parse:
			'D:\TestsExperiements\CACP\wlp-product-master\wlp-product-master-pom\wlp-product-cc\wlp-product-cc-cards-batch\target\classes\net\atos\wlp\cedicam\cc\cardschemeimp\enums\JobList.class[
	net.atos.wlp.cedicam.com.batch.BatchTest,
]
D:\TestsExperiements\CACP\wlp-product-master\wlp-product-master-pom\wlp-product-cc\wlp-product-cc-cards-batch\target\classes\net\atos\wlp\cedicam\cc\cardschemeimp\sicbimport\SicbBinImportLauncher.class[
	net.atos.wlp.cedicam.com.batch.BatchTest,
]'
]
