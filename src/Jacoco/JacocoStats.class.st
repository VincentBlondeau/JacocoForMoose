"
model := MooseModel new.
model importFromMSEStream: (StandardFileStream readOnlyFileNamed: 'artifacts/model.mse').
model install.

JacocoImport runOn: model.
InfinitestImport  runOn: model.


JacocoStats new statsOn: model.

process := nil.
[ 
MessageTally terminateTimerProcess.
process := [JacocoStats new statsOn: model.] fork.
TimeProfiler spyOnProcess: process forMilliseconds: 2000.
 ] ensure: [process terminate.]

Please comment me using the following template inspired by Class Responsibility Collaborator (CRC) design:

For the Class part:  State a one line summary. For example, ""I represent a paragraph of text"".

For the Responsibility part: Three sentences about my main responsibilities - what I do, what I know.

For the Collaborators Part: State my main collaborators and one line about how I interact with them. 

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	cacheNumberOfNotIgnoredTestMethods:		<Object>
	index:		<Object>


    Implementation Points
"
Class {
	#name : #JacocoStats,
	#superclass : #MooseOperator,
	#instVars : [
		'index',
		'cacheNumberOfNotIgnoredTestMethods'
	],
	#category : #Jacoco
}

{ #category : #stats }
JacocoStats >> calculateGainDataOn: res [
	| elements |
	elements := res collect: [ :e | self calculateGainOn: e ] thenReject: #isNil.
	^ elements asOrderedCollection average
]

{ #category : #stats }
JacocoStats >> calculateGainOn: aDictionary [
	| positives allTests |
	allTests := self numberOfNotIgnoredTestMethods.
	positives := aDictionary at: #positives.
	Halt if: [positives isNotEmpty].
	^ 1 - (positives size asFloat / allTests asFloat)
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
JacocoStats >> createDictionaryForMethod: method FromPostives: positives realData: realData all: all [
	"All is set at nil because it is not needed for the experiement"
	| tp fn fp |
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
JacocoStats >> makeInfinitestStatsOn: method [
	| positives realData    |
	positives := method staticlyFoundInfinitestTestMethodsCallingMyself.
	"all := method staticlyFoundAnyTestMethodsCallingMyself."
	realData := (method coveredByJacocoTestMethods select: [ :m | m isNotIgnoredTest ]) asOrderedCollection.
	^ self
		createDictionaryForMethod: method
		FromPostives: positives
		realData: realData
		all: nil
]

{ #category : #stats }
JacocoStats >> makeStaticCallAndAccessAndInheritanceStatsOn: method [
	| positives realData |
	positives := method staticlyFoundJacocoTestMethodsCallingMyselfUsingNotOnlyAccesses.
	realData := (method coveredByJacocoTestMethods select: [ :m | m isNotIgnoredTest ]) asOrderedCollection.
	^ self
		createDictionaryForMethod: method
		FromPostives: positives
		realData: realData
		all: nil
]

{ #category : #stats }
JacocoStats >> makeStaticStatsOn: method [
	| positives all realData |
	positives := method staticlyFoundJacocoTestMethodsCallingMyself.
	all := method staticlyFoundAnyTestMethodsCallingMyself.
	realData := (method coveredByJacocoTestMethods select: [ :m | m isNotIgnoredTest ]) asOrderedCollection.
	^ self
		createDictionaryForMethod: method
		FromPostives: positives
		realData: realData
		all: nil
]

{ #category : #deprecated }
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

{ #category : #deprecated }
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
JacocoStats >> numberOfNotIgnoredTestMethods [
	^ cacheNumberOfNotIgnoredTestMethods
		ifNil:
			[ 
			cacheNumberOfNotIgnoredTestMethods := model allNotIgnoredTestMethods
				size ]
]

{ #category : #deprecated }
JacocoStats >> shouldHalt [
	index ifNil: [ index := 0 ].
	self crLog: index.
	index := index + 1.
	Halt onCount: 1000
]

{ #category : #stats }
JacocoStats >> statsOn: aMooseModel [
	model := aMooseModel .
	^ {(self statsOn: aMooseModel methodSelector: #makeStaticStatsOn: dicoEntry: #jacocoVSStatic).
	(self statsOn: aMooseModel methodSelector: #makeInfinitestStatsOn: dicoEntry: #jacocoVSInfinitest).
	(self statsOn: aMooseModel methodSelector: #makeStaticCallAndAccessAndInheritanceStatsOn: dicoEntry: #jacocoVSStaticWithAll)}
]

{ #category : #stats }
JacocoStats >> statsOn: aMooseModel methodSelector: aMethodSelector dicoEntry: dicoEntry [
	| precisionMean recallMean res gainData |
	res := (aMooseModel allModelMethods reject: #isStub) collect: [ :m | self perform: aMethodSelector with: m ].
	precisionMean := self calculatePrecisionMeanOn: res.
	recallMean := self calculateRecallMeanOn: res.
	gainData := self calculateGainDataOn: res.
	^ dicoEntry
		->
			{(#recall -> recallMean).
			(#precision -> precisionMean).
			(#data -> res).
			(#gain -> gainData)} asDictionary
]

{ #category : #stats }
JacocoStats >> statsStaticCallAndAccessAndInheritanceOn: aMooseModel [
	| precisionMean recallMean res |
	res := (aMooseModel allModelMethods reject: #isStub) collect: [ :m | self calculateStaticCallAndAccessAndInheritanceStatsOn: m ].
	precisionMean := self calculatePrecisionMeanOn: res.
	recallMean := self calculateRecallMeanOn: res.
	^ #jacocoVSStatic
		->
			{(#recall -> recallMean).
			(#precision -> precisionMean).
			(#data -> res)} asDictionary
]

{ #category : #accessing }
JacocoStats >> stream [
	^ 'export.csv' asFileReference writeStream
]
