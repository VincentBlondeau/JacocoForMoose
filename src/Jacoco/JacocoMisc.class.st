Class {
	#name : #JacocoMisc,
	#superclass : #MooseOperator,
	#instVars : [
		'testClass'
	],
	#category : #'Jacoco-Import'
}

{ #category : #'as yet unclassified' }
JacocoMisc >> misc1 [
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
	
	positives := m callingCoveredTestsClasses.
	all := m callingTestsClasses.
	realData := m coveredByTestClasses flatCollect: [ :c | c methods select: [:m2 | m2 isTest and: [ m2 isIgnored not ] ]].
	
	tp := positives intersection: realData.
	fn := realData difference: positives.
	fp := positives difference: realData.
	tn := (all difference: realData ) difference: positives .
	"nom - couverte - tp & cie"

	stream << (m mooseName, ';', m isCoveredByTestClasses asString, ';', tp size asString, ';', fn size asString, ';',fp size asString, ';', tn size asString).
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

(coveredMethods collect: [ :m | m callingCoveredTestsClasses  ] ) flatten.








self asOrderedCollection select: [ :class | class  sourceAnchor fileName beginsWith: './wlp-product-test' ].
]
