Class {
	#name : #JacocoStats,
	#superclass : #MooseOperator,
	#instVars : [
		'testClass',
		'index'
	],
	#category : #Jacoco
}

{ #category : #stats }
JacocoStats >> calculateInfinitestStatsOn: method [
	| positives realData tp fn fp |
	positives := method staticlyFoundInfinitestTestMethodsCallingMyself.
	"all := method staticlyFoundAnyTestMethodsCallingMyself."
	realData := (method coveredByJacocoTestMethods select: [:m | m isNotIgnoredTest ]) asOrderedCollection.
	tp := positives intersection: realData.
	fn := realData difference: positives.
	fp := positives difference: realData.
	"tn := (all difference: realData) difference: positives."
	"nom - couverte - tp & cie"
	^ {(#mooseName -> method mooseName).
	(#isCoveredByJacocoTestMethods -> method isCoveredByJacocoTestMethods).
	(#tp -> tp).
	(#fn -> fn).
	(#fp -> fp).
	(#positives -> positives).
	(#jacoco -> realData)	".
	(#tn -> tn)"} asDictionary
]

{ #category : #stats }
JacocoStats >> calculatePrecisionMeanOn: res [
	| elements |
	elements := res
		collect: [ :e | self calculatePrecisionOn: e ]
		thenReject: #isNil.
	^ elements asOrderedCollection average
]

{ #category : #stats }
JacocoStats >> calculatePrecisionOn: aDictionary [
	| tp fp |
	tp := aDictionary at: #tp.
	fp := aDictionary at: #fp.
	^ tp size + fp size = 0
		ifTrue: [ nil ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fp size asFloat) ]
]

{ #category : #stats }
JacocoStats >> calculateRecallMeanOn: res [
		| elements |
	elements := res
		collect: [ :e | self calculateRecallOn: e ]
		thenReject: #isNil.
	^ elements asOrderedCollection average
]

{ #category : #stats }
JacocoStats >> calculateRecallOn: aDictionary [
	| tp fn |
	tp := aDictionary at: #tp.
	fn := aDictionary at: #fn.
	^ tp size + fn size = 0
		ifTrue: [ nil ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fn size asFloat) ]
]

{ #category : #stats }
JacocoStats >> calculateStaticStatsOn: method [
	| positives all realData tp fn fp tn |
	positives := method staticlyFoundJacocoTestMethodsCallingMyself.
	all := method staticlyFoundAnyTestMethodsCallingMyself.
	realData := method coveredByJacocoTestMethods asMooseGroup selectNotIgnoredTests asOrderedCollection.
	tp := positives intersection: realData.
	fn := realData difference: positives.
	fp := positives difference: realData.
	tn := (all difference: realData) difference: positives.
	"nom - couverte - tp & cie"
	^ {(#mooseName -> method mooseName).
	(#isCoveredByJacocoTestMethods -> method isCoveredByJacocoTestMethods).
	(#tp -> tp).
	(#fn -> fn).
	(#fp -> fp).
	(#positives -> positives).
	(#jacoco -> realData)} asDictionary
]

{ #category : #'as yet unclassified' }
JacocoStats >> calculateStatsOn: methods [
	| positives all realData tp fn fp tn |
	positives := methods staticlyFoundJacocoTestMethodsCallingMyself.
	all := methods staticlyFoundAnyTestMethodsCallingMyself.
	realData := methods coveredByJacocoTestMethods asMooseGroup selectNotIgnoredTests asOrderedCollection.	" flatCollect: [ :c | c methods select: [ :m2 | m2 isTest and: [ m2 isIgnored not ] ] ]"
	tp := positives intersection: realData.
	fn := realData difference: positives.
	fp := positives difference: realData.
	tn := (all difference: realData) difference: positives.
	"nom - couverte - tp & cie"
	^ {(#mooseName -> methods mooseName).
	(#isCoveredByJacocoTestMethods -> methods isCoveredByJacocoTestMethods).
	(#tp -> tp).
	(#fn -> fn).
	(#fp -> fp).
	(#tn -> tn)} asDictionary
	"stream cr.
			{tp size.
			fn size.
			fp size.
			tn size.
			positives.
			(tp size + fp size = 0
				ifTrue: [ nil ]
				ifFalse: [ tp size / (tp size + fp size) ]).
			(tp size + fn size = 0
				ifTrue: [ nil ]
				ifFalse: [ tp size / (tp size + fn size) ])} "
]

{ #category : #'grammar-character' }
JacocoStats >> misc [
	| tp fn tn fp positives all realData stream coveredMethods res total precision recall |
	"Some code to export jacoco data to csv"
	"model := MooseModel root first.
JacocoImport runOn: model."
	"coveredMethods := (model allMethods select: #isCoveredByTestClasses).
coveringTests := (model allMethods select: #isCoveringMethods).

(coveredMethods collect: [ :m | m isCallingCoveredTestsClasses ] ) asBag."
	stream := 'export.csv' asFileReference writeStream.
	res := coveredMethods
		reject:
			[ :m | 
			(m isStub or: [ m belongsTo mooseName = 'net::atos::wlp::cedicam::AbstractTest' ])
				or: [ m belongsTo mooseName = 'net::atos::wlp::cedicam::RootAbstractTest' ] ].
	res := (model allModelMethods reject: #isStub)
		collect:
			[ :m | 
			positives := m staticlyFoundJacocoTestMethodsCallingMyself.
			all := m staticlyFoundAnyTestMethodsCallingMyself.
			realData := m coveredByJacocoTestMethods flatCollect: [ :c | c methods select: [ :m2 | m2 isTest and: [ m2 isIgnored not ] ] ].
			tp := positives intersection: realData.
			fn := realData difference: positives.
			fp := positives difference: realData.
			tn := (all difference: realData) difference: positives.
			"nom - couverte - tp & cie"
			stream
				<<
					(m mooseName , ';' , m isCoveredByJacocoTestMethods asString , ';' , tp size asString , ';' , fn size asString , ';' , fp size asString
						, ';' , tn size asString).
			stream cr.
			{tp size.
			fn size.
			fp size.
			tn size.
			positives.
			(tp size + fp size = 0
				ifTrue: [ nil ]
				ifFalse: [ tp size / (tp size + fp size) ]).
			(tp size + fn size = 0
				ifTrue: [ nil ]
				ifFalse: [ tp size / (tp size + fn size) ])} ].
	stream close.
	res asOrderedCollection.
	(res collect: #sixth) asOrderedCollection average asFloat.
	(res collect: #seventh) asOrderedCollection average asFloat.
	total := res asOrderedCollection reduce: [ :a :b | (a first: 4) + (b first: 4) ].
	precision := total first / (total first + total third).
	recall := total first / (total first + total second).
	{precision asFloat.
	recall asFloat}.
	(coveredMethods collect: [ :m | m staticlyFoundJacocoTestMethodsCallingMyself ]) flatten.
	self asOrderedCollection select: [ :class | class sourceAnchor fileName beginsWith: './wlp-product-test' ]
]

{ #category : #'as yet unclassified' }
JacocoStats >> misc1 [
	"Some code to export jacoco data to csv"
	"model := MooseModel root first.
JacocoImport runOn: model."

"coveredMethods := (model allMethods select: #isCoveredByTestClasses).
coveringTests := (model allMethods select: #isCoveringMethods).

(coveredMethods collect: [ :m | m isCallingCoveredTestsClasses ] ) asBag."
|tp fn tn fp positives all realData stream coveredMethods res total precision recall |

stream := 'export.csv' asFileReference writeStream.
res := (coveredMethods reject: [:m | (m isStub or: [ m belongsTo mooseName = 'net::atos::wlp::cedicam::AbstractTest']) or: [ m belongsTo mooseName = 'net::atos::wlp::cedicam::RootAbstractTest'  ] ]).
res := 	((model allModelMethods  reject: #isStub )collect: [ :m | 
	
	positives := m staticlyFoundJacocoTestMethodsCallingMyself.
	all := m staticlyFoundAnyTestMethodsCallingMyself.
	realData := m coveredByJacocoTestMethods flatCollect: [ :c | c methods select: [:m2 | m2 isTest and: [ m2 isIgnored not ] ]].
	
	tp := positives intersection: realData.
	fn := realData difference: positives.
	fp := positives difference: realData.
	tn := (all difference: realData ) difference: positives .
	"nom - couverte - tp & cie"

	stream << (m mooseName, ';', m isCoveredByJacocoTestMethods asString, ';', tp size asString, ';', fn size asString, ';',fp size asString, ';', tn size asString).
	stream cr.
		
	{  tp size . fn size . fp size. tn size . positives . (tp size  + fp size) = 0  ifTrue:[nil] ifFalse: [tp size / (tp size +  fp size)].(tp size  + fn size) = 0 ifTrue:[nil] ifFalse: [tp size / (tp size +  fn size)]}
	 ] ) .
stream close.


res asOrderedCollection.
(res collect: #sixth) asOrderedCollection average asFloat. 
(res collect: #seventh)asOrderedCollection  average asFloat.
total := res asOrderedCollection reduce: [ :a :b | (a first: 4) + (b first:4) ] .
precision := total first / (total first + total third).
recall :=  total first / (total first + total second). 
{precision asFloat . recall asFloat }.

(coveredMethods collect: [ :m | m staticlyFoundJacocoTestMethodsCallingMyself  ] ) flatten.








self asOrderedCollection select: [ :class | class  sourceAnchor fileName beginsWith: './wlp-product-test' ].
]

{ #category : #'as yet unclassified' }
JacocoStats >> shouldHalt [
	index ifNil: [ index := 0 ].
	self crLog: index.
	index := index + 1.
	Halt onCount: 1000
]

{ #category : #stats }
JacocoStats >> statsOn: aMooseModel [
	| res precisionMean recallMean return temp |
	"coveredMethods := aMooseModel allModelMethodsCoveredByJacocoTestCases.
	coveringTestsMethods := aMooseModel testsMethodsCoveringJacocoMethods."
	res := (aMooseModel allModelMethods reject: #isStub)
		collect: [ :m | self calculateStaticStatsOn: m ].
	precisionMean := self calculatePrecisionMeanOn: res.
	recallMean := self calculateRecallMeanOn: res.
	return := #jacocoVSStatic
		->
			{(#recall -> recallMean).
			(#precision -> precisionMean).
			(#data -> res)} asDictionary.
	temp := aMooseModel allModelMethods reject: #isStub.
	res := temp collect: [ :m | self calculateInfinitestStatsOn: m ].
	"self shouldHalt."
	"self shouldHalt."

	"bag := res collect: [ :i | i at: #isCoveredByJacocoTestMethods ] as: Bag."
	precisionMean := self calculatePrecisionMeanOn: res.
	recallMean := self calculateRecallMeanOn: res.
	^ {return.
	(#jacocoVSInfinitest
		->
			{(#recall -> recallMean).
			(#precision -> precisionMean).
			(#data -> res)} asDictionary)}
	"	(res collect: #sixth) asOrderedCollection average asFloat.
	(res collect: #seventh) asOrderedCollection average asFloat.
	total := res asOrderedCollection reduce: [ :a :b | (a first: 4) + (b first: 4) ].
	precision := total first / (total first + total third).
	recall := total first / (total first + total second).
	{precision asFloat.
	recall asFloat}
"	"(coveredMethods collect: [ :m | m staticlyFoundJacocoTestMethodsCallingMyself ]) flatten.
	self asOrderedCollection select: [ :class | class sourceAnchor fileName beginsWith: './wlp-product-test' ]"
]

{ #category : #accessing }
JacocoStats >> stream [
	^ 'export.csv' asFileReference writeStream
]
