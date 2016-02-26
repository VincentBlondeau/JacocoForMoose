"
MooseModel resetMeta.

model := MooseModel new.
model importFromMSEStream: (StandardFileStream readOnlyFileNamed: 'artifacts/model.mse').
model install.

JacocoImport runOn: model.
InfinitestImport  runOn: model.


JacocoStats new statsOn: model.

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
	index:		<Object>


    Implementation Points
"
Class {
	#name : #JacocoStats,
	#superclass : #MooseOperator,
	#instVars : [
		'index',
		'testGetterSetter'
	],
	#category : #'Jacoco-TestSelection'
}

{ #category : #accessing }
JacocoStats >> allNotStubMethods [
	^ self model allModelMethods reject: [ :e | e isStub ]
]

{ #category : #'as yet unclassified' }
JacocoStats >> avgNumberOfMethodsCoveredByATest [
	^ (self selectAllJacocoTestMethods
		average: [ :test | test coverJacocoMethods size ]) asFloat
]

{ #category : #'as yet unclassified' }
JacocoStats >> avgNumberOfTestsThatCoversAMethod [
	^ (self selectMethodsFromModel
		average: [ :meth | meth coveredByJacocoTestMethods size ]) asFloat
]

{ #category : #'stats - generic' }
JacocoStats >> basicRun [
	^ self statsOn: self model
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateCommitNotNullWeightedMeanOfMetric: metricName on: res [
	| collOfWeightedElements size sum |
	collOfWeightedElements := res collect: [ :e | self calculateWeightedMetric: metricName on: e ] thenReject: [ :e | e first isNil or: [ e second = 0 ] ].
	size := collOfWeightedElements sum: #second.
	sum := collOfWeightedElements sum: [ :item | item first * item second ].
	^ {(sum / size).
	collOfWeightedElements}
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateGainDataOn: res [
	| elements numberOfTests avgWithoutZeros gainWithoutZeros gainWithZeros avgWithZeros numberOfZeros |

	numberOfTests := self numberOfTestsMethodsFromModel: model. 
	
	elements := res collect: [ :e | self calculateGainOn: e ] thenReject: #isNil.
	avgWithoutZeros := (elements asOrderedCollection
		removeAllSuchThat: [ :f | f closeTo: 0.0 ];
		yourself) average.
	gainWithoutZeros := 1 - (avgWithoutZeros / numberOfTests).
	gainWithZeros := 1 - (elements average / numberOfTests).
	avgWithZeros := elements average.
	numberOfZeros := elements asOrderedCollection occurrencesOf: 0.
	^ {elements asBag.
	{(#avgWithoutZeros -> avgWithoutZeros).
	(#gainWithoutZeros -> gainWithoutZeros).
	(#gainWithZeros -> gainWithZeros).
	(#avgWithZeros -> avgWithZeros).
	(#numberOfZeros -> numberOfZeros)} asDictionary}
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateGainOn: aDictionary [
	^ (aDictionary at: #positives) size asFloat
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateMeanOfMetric: metricName on: res [
	| elements |
	elements := res collect: [ :e | self perform: (self metricMethod: metricName) with: e ] thenReject: #isNil.
	^ elements asOrderedCollection average
]

{ #category : #'metrics calculus' }
JacocoStats >> calculatePrecisionOn: aDictionary [
	| tp fp prec |
	tp := aDictionary at: #tp.
	fp := aDictionary at: #fp.
	prec := tp size + fp size = 0
		ifTrue: [ nil ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fp size asFloat) ].
	aDictionary at: #Prec put: prec.
	^ prec
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateRecallOn: aDictionary [
	| tp fn recall |
	tp := aDictionary at: #tp.
	fn := aDictionary at: #fn.
	recall := tp size + fn size = 0
		ifTrue: [ nil ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fn size asFloat) ].
	aDictionary at: #Recall put: recall.
	^ recall
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateWeightedMeanOfMetric: metricName on: res [
	| collOfWeightedElements size sum |
	collOfWeightedElements := res
		collect: [ :e | self calculateWeightedMetric: metricName on: e ]
		thenReject: [ :e | e first isNil ].
	size := collOfWeightedElements sum: #second.
	sum := collOfWeightedElements sum: [ :item | item first * item second ].
	^ {(sum / size).
	collOfWeightedElements}
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateWeightedMetric: metricName on: aCollectionOfData [
	| metricValue |
	metricValue := self perform: (self metricMethod: metricName) with: aCollectionOfData.
	^ {metricValue.
	(aCollectionOfData at: #numberOfCommits)}
]

{ #category : #'stats - generic' }
JacocoStats >> createDictionaryForMethod: method fromPostives: positives realData: realData all: all [
	"All is set at nil because it is not needed for the experiement"

	| tp fn fp |
	tp := positives intersection: realData.
	fn := realData difference: positives.
	fp := positives difference: realData.
	"tn := (all difference: realData) difference: positives."
	"nom - couverte - tp & cie"
	^ {(#method -> method).
	(#mooseName -> method mooseName).
	(#isCoveredByJacocoTestMethods -> method isCoveredByJacocoTestMethods).
	(#tp -> tp).
	(#fn -> fn).
	(#fp -> fp).
	(#positives -> positives).
	(#jacoco -> realData).
	(#greenTests -> (realData collect: #testStatus)).
	(#numberOfCommits -> method belongsTo numberOfCommits)
	".
	(#tn -> tn)"} asDictionary
]

{ #category : #testing }
JacocoStats >> isMethodAnchorInTheCoreDir: method [
	^ method sourceAnchor
		ifNil: [ method belongsTo sourceAnchor fileName beginsWith: '/main/' ]
		ifNotNil: [ :sa | sa fileName includesSubstring: '/main/' ]
]

{ #category : #testing }
JacocoStats >> isMethodAnchorInTheTestDir: method [
	^ method sourceAnchor
		ifNil: [ method belongsTo sourceAnchor fileName beginsWith: '/test/' ]
		ifNotNil: [ :sa | sa fileName includesSubstring: '/test/' ]
]

{ #category : #'metrics calculus' }
JacocoStats >> makeStatsOnMethod: method withSelector: aMethodSelector [
	| mapping positives realData |
	mapping := self mappingToMethodGetters at: aMethodSelector.
	positives := (method perform: mapping) reject: self toRemove.
	realData := self selectMethodsCovering: method.
	^ self
		createDictionaryForMethod: method
		fromPostives: positives
		realData: realData
		all: nil
]

{ #category : #'stats - generic' }
JacocoStats >> mappingToMethodGetters [
	^ {(#makeInfinitestStatsOn: -> #staticlyFoundInfinitestTestMethodsCallingMyself).
	(#makeStaticAccessAndInnerAndInheritanceStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritance).
	(#makeStaticAccessAndInnerAndInheritanceAndCallableStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritanceAndCallable).
	(#makeStaticAccessAndInnerStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInner).
	(#makeStaticAccessStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyselfUsingAccess).
	(#makeStaticCallAndInheritanceStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyselfUsingInheritance).
	(#makeStaticClassStatsOn: -> #staticlyFoundByClassJacocoTestMethodsCallingMyself).
	(#makeStaticInnerclassesStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyselfUsingInnerclasses).
	(#makeStaticStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyself).
	(#makeStaticCallableStatsOn: -> #staticlyFoundJacocoTestMethodsCallingMyselfUsingCallable)} asDictionary
]

{ #category : #'metrics calculus' }
JacocoStats >> metricMethod: metricName [
	^ ('calculate' , metricName , 'On:') asSymbol
]

{ #category : #accessing }
JacocoStats >> numberOfTestsMethodsFromModel: aMooseModel [
	^ ((self allNotStubMethods select: [ :m | (self isMethodAnchorInTheTestDir: m) and: [ m isCoveringJacocoMethods ] ]) reject: self toRemove) size
]

{ #category : #accessing }
JacocoStats >> selectAllCoreMethods [
	^ self allNotStubMethods select: [ :m | self isMethodAnchorInTheCoreDir: m ]
]

{ #category : #accessing }
JacocoStats >> selectAllJacocoTestMethods [
	^ self allNotStubMethods
		select:
			[ :m | (self isMethodAnchorInTheTestDir: m)
				and: [ m isCoveringJacocoMethods  ] ]
]

{ #category : #accessing }
JacocoStats >> selectAllTestMethods [
	^ self allNotStubMethods select: [ :m | self isMethodAnchorInTheTestDir: m ]
]

{ #category : #accessing }
JacocoStats >> selectMethodsCovering: method [
	^ (method coveredByJacocoTestMethods select: [ :m | m isNotIgnoredTest ])
		reject: self toRemove
]

{ #category : #accessing }
JacocoStats >> selectMethodsFromModel [
	^ self allNotStubMethods select: [ :m | (self isMethodAnchorInTheCoreDir: m) and: [ m isCoveredByJacocoTestMethodsByRejecting: self toRemove ] ]
]

{ #category : #halting }
JacocoStats >> shouldHalt [
	index ifNil: [ index := 0 ].
	self crLog: index.
	index := index + 1.
	Halt onCount: 1000
]

{ #category : #accessing }
JacocoStats >> shouldRemoveSpecificly: element [
	^ false
]

{ #category : #'stats - generic' }
JacocoStats >> statsOn: aMooseModel [
	^ {(#numberOfCoreMethods -> self selectAllCoreMethods).
	(#numberOfTestMethods -> self selectAllTestMethods).
	(#LOCCovered
		->
			((self selectAllCoreMethods select: [ :item | item isCoveredByJacocoTestMethods ])
				sum: #numberOfLinesOfCode)).
	(#numberOfJacocoTests
		-> (self selectAllTestMethods select: [ :item | item isCoveringJacocoMethods ]) size).
	(#NLOCCore -> (self selectAllCoreMethods sum: #numberOfLinesOfCode)).
	(#NLOCTest
		->
			((self selectAllTestMethods select: [ :item | item isCoveringJacocoMethods ])
				sum: #numberOfLinesOfCode)).
	(#numberOfMethodsCovered -> self selectMethodsFromModel size).
	(#avgNumberOfMethodsCoveredByATest -> self avgNumberOfMethodsCoveredByATest).
	(#avgNumberOfTestsThatCoversAMethod -> self avgNumberOfTestsThatCoversAMethod).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticCallableStatsOn:
		dicoEntry: #jacocoVSStaticWithCallables).
	(self
		statsOn: aMooseModel
		methodSelector: #makeInfinitestStatsOn:
		dicoEntry: #jacocoVSInfinitest).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticStatsOn:
		dicoEntry: #jacocoVSStatic).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticCallAndInheritanceStatsOn:
		dicoEntry: #jacocoVSStaticWithInheritance).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticClassStatsOn:
		dicoEntry: #jacocoVSStaticClass).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticInnerclassesStatsOn:
		dicoEntry: #jacocoVSStaticWithInner).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessStatsOn:
		dicoEntry: #jacocoVSStaticWithAccess).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessAndInnerStatsOn:
		dicoEntry: #jacocoVSStaticWithAccessAndInner).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessAndInnerAndInheritanceStatsOn:
		dicoEntry: #jacocoVSStaticWithAccessAndInnerAndInheritances).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessAndInnerAndInheritanceAndCallableStatsOn:
		dicoEntry: #jacocoVSStaticWithAccessAndInnerAndInheritancesAndCallables)} asDictionary
]

{ #category : #'stats - generic' }
JacocoStats >> statsOn: aMooseModel methodSelector: aMethodSelector dicoEntry: dicoEntry [
	| precisionMean recallMean res methods gainData greenTests recallWeightedMean precisionWeightedMean |
	methods := self selectMethodsFromModel.
	res := methods collect: [ :m | self makeStatsOnMethod: m withSelector: aMethodSelector ].
	precisionMean := self calculateMeanOfMetric: #Precision on: res.
	recallMean := self calculateMeanOfMetric: #Recall on: res.
	precisionWeightedMean := self calculateWeightedMeanOfMetric: #Precision on: res.
	recallWeightedMean := self calculateWeightedMeanOfMetric: #Recall on: res.
	gainData := self calculateGainDataOn: res.
	greenTests := res flatCollect: [ :e | e at: #greenTests ].
	^ dicoEntry
		->
			{(#recall -> recallMean).
			(#precision -> precisionMean).
			(#recallWeighted -> recallWeightedMean).
			(#precisionWeighted -> precisionWeightedMean).
			(#recallWeightedCommitNotNull
				-> (self calculateCommitNotNullWeightedMeanOfMetric: #Recall on: res)).
			(#precisionWeightedCommitNotNull
				-> (self calculateCommitNotNullWeightedMeanOfMetric: #Precision on: res)).
			(#data -> res).
			(#gainData -> gainData first).
			(#gain -> gainData second).
			(#percentageOfGreenTests
				-> ((greenTests occurrencesOf: 'pass') / greenTests size) asFloat)} asDictionary
]

{ #category : #accessing }
JacocoStats >> toRemove [
	^ [ :e | (self shouldRemoveSpecificly: e) or: [ e testIsGreen not ] ]
]
