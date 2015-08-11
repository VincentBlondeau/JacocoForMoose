Class {
	#name : #JacocoStats,
	#superclass : #MooseOperator,
	#instVars : [
		'testClass'
	],
	#category : #Jacoco
}

{ #category : #'as yet unclassified' }
JacocoStats >> calculatePrecisionMeanOn: res [
	| elements |
	elements := res
		collect: [ :e | self calculatePrecisionOn: e ]
		thenReject: #isNil.
	self halt.
	^ res average: [ :e | self calculatePrecisionOn: e ]
]

{ #category : #'as yet unclassified' }
JacocoStats >> calculatePrecisionOn: aDictionary [
	| tp fp |
	tp := aDictionary at: #tp.
	fp := aDictionary at: #fp.
	^ tp size + fp size = 0
		ifTrue: [ nil ]
		ifFalse: [ tp size / (tp size + fp size) ]
]

{ #category : #'as yet unclassified' }
JacocoStats >> calculateRecallMeanOn: res [
	^ res average: [ :e | self calculateRecallOn: e ]
]

{ #category : #'as yet unclassified' }
JacocoStats >> calculateRecallOn: aDictionary [
	| tp fn |
	tp := aDictionary at: #tp.
	fn := aDictionary at: #fn.
	^ tp size + fn size = 0
		ifTrue: [ Float nan ]
		ifFalse: [ tp size / (tp size + fn size) ]
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
JacocoStats >> statsOn: aMooseModel [
	| res total precision recall jacocoTests bag |
	"coveredMethods := aMooseModel allModelMethodsCoveredByJacocoTestCases.
	coveringTestsMethods := aMooseModel testsMethodsCoveringJacocoMethods."
	res := (aMooseModel allModelMethods reject: #isStub) collect: [ :m | self calculateStatsOn: m ].
	bag := res collect: [ :i | i at: #isCoveredByJacocoTestMethods ] as: Bag.
	jacocoTests := res select: [ :i | i at: #isCoveredByJacocoTestMethods ].
	self calculatePrecisionMeanOn: res.
	self calculateRecallMeanOn: res.
	"self calculatePrecisionMeanOn: jacocoTests.
	self calculateRecallMeanOn: jacocoTests."
	self halt.
	(res collect: #sixth) asOrderedCollection average asFloat.
	(res collect: #seventh) asOrderedCollection average asFloat.
	total := res asOrderedCollection reduce: [ :a :b | (a first: 4) + (b first: 4) ].
	precision := total first / (total first + total third).
	recall := total first / (total first + total second).
	{precision asFloat.
	recall asFloat}
	"(coveredMethods collect: [ :m | m staticlyFoundJacocoTestMethodsCallingMyself ]) flatten.
	self asOrderedCollection select: [ :class | class sourceAnchor fileName beginsWith: './wlp-product-test' ]"
]

{ #category : #accessing }
JacocoStats >> stream [
	^ 'export.csv' asFileReference writeStream
]
