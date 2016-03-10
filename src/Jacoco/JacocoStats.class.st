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
		'testGetterSetter',
		'cache'
	],
	#category : #'Jacoco-TestSelection'
}

{ #category : #'as yet unclassified' }
JacocoStats class >> experimentNameMapping [
	^ {('0-jacocoVSStaticWithAccessAndInnerAndInheritances' -> '00').
	('1-jacocoVSInfinitest' -> '1-Infinitest').
	('2-jacocoVSStaticClass' -> '2-Moose (classes)').
	('3-jacocoVSStatic' -> '3-Moose (methods)').
	('4-jacocoVSStaticWithCallables' -> '4-Moose w/ delayed execution').
	('5-jacocoVSStaticWithInner' -> '5-Moose w/ anonymous classes').
	('6-jacocoVSStaticWithAccess' -> '6-Moose w/ attributes').
	('7-jacocoVSStaticWithInheritance' -> '7-Moose w/ polymorphism').
	('8-jacocoVSStaticWithAccessAndInner' -> '01').
	('9-jacocoVSStaticWithAccessAndInnerAndInheritancesAndCallables'
		-> '8-Moose w/ att. \& anon. \& pol. \& delayed execution')} asDictionary
]

{ #category : #'as yet unclassified' }
JacocoStats class >> exportStatData: aCollection withProjectName: projectName [
	| data stream writter |
	data := aCollection select: #isDictionary.
	[ stream := StandardFileStream forceNewFileNamed: 'c:\tmp\export-stats.csv'.
	writter := (NeoCSVWriter on: stream)
		separator: $;;
		yourself.
	"nextPut: variables;"
	data
		associationsDo:
			[ :aDico | self obtainStatsFrom: aDico projectName: projectName writter: writter ] ]
		ensure: [ stream close ]
]

{ #category : #'as yet unclassified' }
JacocoStats class >> exportToCSV: aCollection [
	| data variables vals gain values stream writter gainCommit |
	data := aCollection select: #isDictionary.
	variables := #(#Exp #Gain #Gainavg #NumOfZeros #GainCommit #GainCommitavg #CommitNumOfZeros #GainFineGrainedWeightedMean #Precision #PrecisionCommitMeaned #precisionCommitRandomMeaned #PrecisionFineGrainedWeightedMean #cor #pvalue #PrecisionWeighted #cor #pvalue #Recall #RecallCommitMeaned #recallCommitRandomMeaned #RecallFineGrainedWeightedMean #cor #pvalue #RecallWeighted #cor #pvalue #fMeasure #fMeasureCommitMeaned #fMeasureFineGrainedWeightedMean).	"#PrecisionWeightedNotNull #cor #pvalue"	"#RecallWeightedNotNull #cor #pvalue"
	values := [ :dico | 
	vals := dico value.
	gain := vals at: #gain.
	gainCommit := vals at: #gainCommit.
	{dico key.
	(gain at: #avgWithZeros).
	(gain at: #gainWithZeros).
	(gain at: #numberOfZeros).
	(gainCommit at: #avgWithZeros).
	(gainCommit at: #gainWithZeros).
	(gainCommit at: #numberOfZeros).
	(vals at: #gainFineGrainedWeightedMean).
	(vals at: #precision).
	(vals at: #precisionCommitMeaned).
	"(vals at: #precisionCommitRandomMeaned)."
	(vals at: #precisionFineGrainedWeightedMean) first.
	(vals at: #precisionFineGrainedWeightedMean) second .
	(vals at: #precisionFineGrainedWeightedMean) second .
	(vals at: #precisionWeighted) first.
	(vals at: #precisionWeighted) second .
	(vals at: #precisionWeighted) second .
	"	(vals at: #precisionWeightedCommitNotNull) first.
	(vals at: #precisionWeightedCommitNotNull) second first.
	(vals at: #precisionWeightedCommitNotNull) second second."
	(vals at: #recall).
	(vals at: #recallCommitMeaned).
	"(vals at: #recallCommitRandomMeaned)."
	(vals at: #recallFineGrainedWeightedMean) first.
	(vals at: #recallFineGrainedWeightedMean) second .
	(vals at: #recallFineGrainedWeightedMean) second .
	(vals at: #recallWeighted) first.
	(vals at: #recallWeighted) second .
	(vals at: #recallWeighted) second .
	"(vals at: #recallWeightedCommitNotNull) first.
	(vals at: #recallWeightedCommitNotNull) second first.
	(vals at: #recallWeightedCommitNotNull) second second."
	(vals at: #fMeasure).
	(vals at: #fmeasureCommitMeaned).
	(vals at: #fmeasureFineGrainedWeightedMean) first} ].
	[ stream := StandardFileStream forceNewFileNamed: '/tmp/export-dico.csv'.
	writter := (NeoCSVWriter on: stream)
		separator: $;;
		nextPut: variables;
		yourself.
	data associationsDo: [ :aDico | writter nextPut: (values value: aDico) ] ]
		ensure: [ stream close ]
]

{ #category : #'as yet unclassified' }
JacocoStats class >> isRConnectorAvailable [
	^ false 
]

{ #category : #'as yet unclassified' }
JacocoStats class >> numberOfTestOf: aString [
	^ {('P1' -> 5323).
	('P2' -> 168).
	('P3' -> 3035)} asDictionary at: aString
]

{ #category : #'as yet unclassified' }
JacocoStats class >> obtainStatsFrom: anAssociation projectName: projectName writter: writter [
	| expName stats res |
	expName := self experimentNameMapping at: anAssociation key.
	{('gain-unif' -> [ :coll | (coll at: #data) collect: [ :e | (e at: #positives) size / (self numberOfTestOf: projectName) asFloat ] ]).
	('recall-unif' -> [ :coll | (coll at: #data) collect: [ :e | e at: #Recall ] ]).
	('precision-unif' -> [ :coll | (coll at: #data) collect: [ :e | e at: #Prec ] ]).
	('gain-commit' -> [ :coll | (coll at: #dataCommit) collect: [ :e | (e at: #positives) size / (self numberOfTestOf: projectName) asFloat ] ]).
	('recall-commit' -> [ :coll | (coll at: #dataCommit) collect: [ :e | e at: #Recall ] ]).
	('precision-commit' -> [ :coll | (coll at: #dataCommit) collect: [ :e | e at: #Prec ] ])}
		do:
			[ :assoc | 
			| data sd |
			assoc key.
			data := assoc value value: anAssociation value.
			stats := 'summary' asREval: {data}.
			sd := #sd asREval: {data}.
			res := OrderedCollection new
				add: projectName , '-' , expName , '-' , assoc key;
				addAll: stats asObject;
				add: sd first;
				yourself.
			writter nextPut: res ]
]

{ #category : #accessing }
JacocoStats >> allNotStubMethods [
	^ cache at: #allNotStubMethods ifAbsentPut: [self model allModelMethods reject: [ :e | e isStub ]]
]

{ #category : #'as yet unclassified' }
JacocoStats >> avgNumberOfJacocoTestsByCommit [
	^ (self selectCommitsFromModel
		average:
			[ :aCommit | 
			(((aCommit changes flatCollect: #modifiedEntities) select: #isMethod)
				flatCollect: #coveredByJacocoTestMethods) size ]) asFloat
]

{ #category : #'as yet unclassified' }
JacocoStats >> avgNumberOfJacocoTestsFineGrainWeighted [
	| sum size |
	sum := (self selectMethodsFromModel
		sum:
			[ :meth | meth coveredByJacocoTestMethods size * meth numberOfFineGrainedCommits ])
		asFloat.
	size := self selectMethodsFromModel sum: #numberOfFineGrainedCommits.
	^ (sum / size) asFloat
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
	collOfWeightedElements := res collect: [ :e | self calculateWeightedMetric: metricName on: e ] thenReject: [ :e | e first isNil or: [ e second <= 1 ] ].
	size := collOfWeightedElements sum: #second.
	sum := collOfWeightedElements sum: [ :item | item first * item second ].
	^ {(sum / size) round: 4. self calculateCor: collOfWeightedElements.
	collOfWeightedElements}
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateCor: collOfWeightedElements [
	| metric nbCommits cor |
	^ self class isRConnectorAvailable
		ifTrue:
			[ metric := collOfWeightedElements collect: #first as: OrderedCollection.
			nbCommits := collOfWeightedElements collect: #second as: OrderedCollection.
			cor := 'cor.test'
				asREval:
					{metric asOrderedCollection.
					nbCommits asOrderedCollection}.
			{(cor at: 'estimate') asObject round: 4.
			(cor at: 'p.value') asObject round: 4.
			(cor at: 'conf.int') asObject collect: [:e | e round: 4] } ]
		ifFalse: [ nil ]
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateFMeasureOn: aDictionary [
	| tp fp prec fn recall fmeasure |
	tp := aDictionary at: #tp.
	fp := aDictionary at: #fp.
	fn := aDictionary at: #fn.
	prec := tp size + fp size = 0
		ifTrue: [ 0 ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fp size asFloat) ].
	recall := tp size + fn size = 0
		ifTrue: [ 0 ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fn size asFloat) ].
	(recall isNil or: [ prec isNil ])
		ifTrue: [ fmeasure := 0 ]
		ifFalse:
			[ prec + recall = 0
				ifTrue: [ fmeasure := 0 ]
				ifFalse: [ fmeasure := 2 * prec * recall / (prec + recall) asFloat ] ].
	aDictionary at: #FMeasure put: fmeasure.
	^ fmeasure
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateFineGrainedWeightedGainDataOn: res [
	| elements numberOfTests size sum |
	numberOfTests := self numberOfTestsMethodsFromModel: model.
	elements := res
		collect:
			[ :e | 
			{(self calculateGainOn: e).
			(e at: #numberOfFineGrainedCommits)} ]
		thenReject: #isNil.
	size := elements sum: #second.
	sum := elements sum: [ :item | item first * item second ].
	^ sum / size round: 4
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateFineGrainedWeightedMeanOfMetric: metricName on: res [
	| collOfWeightedElements size sum |
	collOfWeightedElements := res
		collect: [ :e | self calculateWeightedMetric: metricName on: e ]
		thenReject: [ :e | e first isNil ].
	size := collOfWeightedElements sum: #fourth.
	sum := collOfWeightedElements sum: [ :item | item first * item fourth ].
	^ {(sum / size) round: 4. self calculateCor: collOfWeightedElements.
	collOfWeightedElements}
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateGainDataOn: res [
	| elements numberOfTests avgWithoutZeros gainWithoutZeros gainWithZeros avgWithZeros numberOfZeros |
	numberOfTests := self numberOfTestsMethodsFromModel: model.
	elements := res collect: [ :e | self calculateGainOn: e ] thenReject: #isNil.
	avgWithoutZeros := (elements asOrderedCollection
		removeAllSuchThat: [ :f | f closeTo: 0.0 ];
		yourself) average round: 3.
	gainWithoutZeros := 1 - (avgWithoutZeros / numberOfTests) round: 3.
	gainWithZeros := 1 - (elements average / numberOfTests) round: 3.
	avgWithZeros := elements average round: 3.
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
	^ elements asOrderedCollection average round: 4
]

{ #category : #'metrics calculus' }
JacocoStats >> calculatePrecisionOn: aDictionary [
	| tp fp prec |
	tp := aDictionary at: #tp.
	fp := aDictionary at: #fp.
	prec := tp size + fp size = 0
		ifTrue: [ 0 ]
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
		ifTrue: [ 0 ]
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
	^ {(sum / size) round: 4. self calculateCor: collOfWeightedElements.
	collOfWeightedElements}
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateWeightedMetric: metricName on: aCollectionOfData [
	| metricValue |
	metricValue := self perform: (self metricMethod: metricName) with: aCollectionOfData.
	^ {metricValue.
	(aCollectionOfData at: #numberOfCommits).
	(aCollectionOfData at: #method).
	(aCollectionOfData at: #numberOfFineGrainedCommits)}
]

{ #category : #'stats - generic' }
JacocoStats >> createDictionaryForCommit: commit fromPostives: positives realData: realData all: all [
	"All is set at nil because it is not needed for the experiement"

	| tp fn fp |
	tp := positives intersection: realData.
	fn := realData difference: positives.
	fp := positives difference: realData.
	"tn := (all difference: realData) difference: positives."
	"nom - couverte - tp & cie"
	^ {(#commit -> commit).
	(#mooseName -> commit mooseName).
	(#tp -> tp).
	(#fn -> fn).
	(#fp -> fp).
	(#positives -> positives).
	(#jacoco -> realData)} asDictionary
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
	(#numberOfCommits -> method belongsTo numberOfCommits).
	(#numberOfFineGrainedCommits -> method numberOfFineGrainedCommits)
	".
	(#tn -> tn)"} asDictionary
]

{ #category : #halting }
JacocoStats >> initialize [
	super initialize.
	cache := Dictionary new
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
JacocoStats >> makeStatsOnCommit: commit withSelector: aMethodSelector [
	| mapping res |
	mapping := self mappingToMethodGetters at: aMethodSelector.
	res := Dictionary new
		at: #positives put: Set new;
		at: #realData put: Set new;
		yourself.
	commit allChangedMethods
		do:
			[ :aMethod | 
			(res at: #positives) addAll: ((aMethod perform: mapping) reject: self toRemove).
			(res at: #realData) addAll: (self selectMethodsCovering: aMethod) ].
	^ self
		createDictionaryForCommit: commit
		fromPostives: (res at: #positives)
		realData: (res at: #realData)
		all: nil
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

{ #category : #'metrics calculus' }
JacocoStats >> makeStatsOnRandom: commit withSelector: aMethodSelector [
	| mapping res |
	mapping := self mappingToMethodGetters at: aMethodSelector.
	res := Dictionary new
		at: #positives put: Set new;
		at: #realData put: Set new;
		yourself.
	(self selectMethodsFromModel
		randomSelect: self meanNumberOfCommitByMethod rounded)
		do:
			[ :aMethod | 
			(res at: #positives)
				addAll: ((aMethod perform: mapping) reject: self toRemove).
			(res at: #realData) addAll: (self selectMethodsCovering: aMethod) ].
	^ self
		createDictionaryForCommit: commit
		fromPostives: (res at: #positives)
		realData: (res at: #realData)
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

{ #category : #'as yet unclassified' }
JacocoStats >> meanNumberOfCommit [
	^ cache
		at: #meanNumberOfCommit
		ifAbsentPut:
			[ (self selectCommitsFromModel
				average: [ :commit | (commit changes select: #isJavaFile) size ])
				asFloat round: 2 ]
]

{ #category : #'as yet unclassified' }
JacocoStats >> meanNumberOfCommitByMethod [
	^ cache
		at: #meanNumberOfCommitByMethod
		ifAbsentPut:
			[ (self selectCommitsFromModel
				average:
					[ :commit | 
					(((commit changes flatCollect: #modifiedEntities) select: #isMethod)
						as: Set) size ]) asFloat round: 2 ]
]

{ #category : #'metrics calculus' }
JacocoStats >> metricMethod: metricName [
	^ ('calculate' , metricName , 'On:') asSymbol
]

{ #category : #'stats - generic' }
JacocoStats >> numberOfRandomRepeats [
	^ 1000
]

{ #category : #accessing }
JacocoStats >> numberOfTestsMethodsFromModel: aMooseModel [
	^ ((self allNotStubMethods select: [ :m | (self isMethodAnchorInTheTestDir: m) and: [ m isCoveringJacocoMethods ] ]) reject: self toRemove) size
]

{ #category : #accessing }
JacocoStats >> selectAllCoreMethods [
	^ cache at: #selectAllCoreMethods ifAbsentPut: [self allNotStubMethods select: [ :m | self isMethodAnchorInTheCoreDir: m ]]
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
	^ cache at: #selectAllTestMethods ifAbsentPut: [ self allNotStubMethods select: [ :m | self isMethodAnchorInTheTestDir: m ]]
]

{ #category : #'as yet unclassified' }
JacocoStats >> selectCommitsFromModel [
	^ self model allJavaCommits select: [:c | c hasAMethodCoveredByJacoco: self  toRemove ]
]

{ #category : #accessing }
JacocoStats >> selectMethodsCovering: method [
	^ (method coveredByJacocoTestMethods select: [ :m | m isNotIgnoredTest ])
		reject: self toRemove
]

{ #category : #accessing }
JacocoStats >> selectMethodsFromModel [
	^ cache
		at: #selectMethodsFromModel
		ifAbsentPut:
			[ self allNotStubMethods
				select:
					[ :m | 
					(self isMethodAnchorInTheCoreDir: m)
						and:
							[ m isCoveredByJacocoTestMethodsByRejecting: self toRemove ] ] ]
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
	(#numberOfCommits -> self selectCommitsFromModel size).
	(#numberOfJavaFilesChangedByCommit -> self meanNumberOfCommit).
	(#numberOfJavaMethodsChangedByCommit -> self meanNumberOfCommitByMethod).

	(#LOCCovered
		->
			((self selectAllCoreMethods select: [ :item | item isCoveredByJacocoTestMethods ])
				sum: #numberOfLinesOfCode)).
	(#numberOfJacocoTests
		->
			(self selectAllTestMethods select: [ :item | item isCoveringJacocoMethods ]) size).
	(#NLOCCore -> (self selectAllCoreMethods sum: #numberOfLinesOfCode)).
	(#NLOCTest
		->
			((self selectAllTestMethods select: [ :item | item isCoveringJacocoMethods ])
				sum: #numberOfLinesOfCode)).
	(#numberOfMethodsCovered -> self selectMethodsFromModel size).
	(#avgNumberOfMethodsCoveredByATest -> self avgNumberOfMethodsCoveredByATest).
	(#avgNumberOfJacocoTestsFineGrainWeighted -> self avgNumberOfJacocoTestsFineGrainWeighted).
	(#avgNumberOfJacocoTestsByCommit -> self avgNumberOfJacocoTestsByCommit).
	(#avgNumberOfTestsThatCoversAMethod -> self avgNumberOfTestsThatCoversAMethod).
	(#numberOfClassCommits
		-> (self allNotStubMethods sum: [ :e | e belongsTo numberOfCommits ])).
	(#numberOfMethodCommits
		-> (self allNotStubMethods sum: [ :e | e numberOfFineGrainedCommits ])).
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticCallableStatsOn:
		dicoEntry: #'4-jacocoVSStaticWithCallables').
	(self
		statsOn: aMooseModel
		methodSelector: #makeInfinitestStatsOn:
		dicoEntry: #'1-jacocoVSInfinitest').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticStatsOn:
		dicoEntry: #'3-jacocoVSStatic').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticCallAndInheritanceStatsOn:
		dicoEntry: #'7-jacocoVSStaticWithInheritance').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticClassStatsOn:
		dicoEntry: #'2-jacocoVSStaticClass').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticInnerclassesStatsOn:
		dicoEntry: #'5-jacocoVSStaticWithInner').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessStatsOn:
		dicoEntry: #'6-jacocoVSStaticWithAccess').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessAndInnerStatsOn:
		dicoEntry: #'8-jacocoVSStaticWithAccessAndInner').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessAndInnerAndInheritanceStatsOn:
		dicoEntry: #'0-jacocoVSStaticWithAccessAndInnerAndInheritances').
	(self
		statsOn: aMooseModel
		methodSelector: #makeStaticAccessAndInnerAndInheritanceAndCallableStatsOn:
		dicoEntry: #'9-jacocoVSStaticWithAccessAndInnerAndInheritancesAndCallables')}
		asDictionary
]

{ #category : #'stats - generic' }
JacocoStats >> statsOn: aMooseModel methodSelector: aMethodSelector dicoEntry: dicoEntry [
	| precisionMean recallMean resMethod resCommit methods gainData greenTests recallWeightedMean precisionWeightedMean gainCommit  fmeasureMean fmeasureWeightedMean |
	methods := self selectMethodsFromModel.
	resMethod := methods collect: [ :m | self makeStatsOnMethod: m withSelector: aMethodSelector ].
	resCommit := self selectCommitsFromModel collect: [ :m | self makeStatsOnCommit: m withSelector: aMethodSelector ].
	"resCommitRandom := (1 to: self numberOfRandomRepeats) collect: [ :m | self makeStatsOnRandom: m withSelector: aMethodSelector ]."
	precisionMean := self calculateMeanOfMetric: #Precision on: resMethod.
	recallMean := self calculateMeanOfMetric: #Recall on: resMethod.
	fmeasureMean := self calculateMeanOfMetric: #FMeasure on: resMethod.
	precisionWeightedMean := self calculateWeightedMeanOfMetric: #Precision on: resMethod.
	recallWeightedMean := self calculateWeightedMeanOfMetric: #Recall on: resMethod.
	fmeasureWeightedMean := self calculateWeightedMeanOfMetric: #FMeasure on: resMethod.
	gainData := self calculateGainDataOn: resMethod.
	gainCommit := self calculateGainDataOn: resCommit.
	greenTests := resMethod flatCollect: [ :e | e at: #greenTests ].
	^ dicoEntry
		->
			{(#recall -> recallMean).
			(#precision -> precisionMean).
			(#fMeasure -> fmeasureMean).
			(#recallWeighted -> recallWeightedMean).
			(#precisionWeighted -> precisionWeightedMean).
			(#fMeasureWeighted -> fmeasureWeightedMean).
			(#precisionCommitMeaned -> (self calculateMeanOfMetric: #Precision on: resCommit)).
			(#recallCommitMeaned -> (self calculateMeanOfMetric: #Recall on: resCommit)).
			(#fmeasureCommitMeaned -> (self calculateMeanOfMetric: #FMeasure on: resCommit)).
			"(#precisionCommitRandomMeaned -> (self calculateMeanOfMetric: #Precision on: resCommitRandom)).
			(#recallCommitRandomMeaned -> (self calculateMeanOfMetric: #Recall on: resCommitRandom)).
			(#fmeasureCommitRandomMeaned -> (self calculateMeanOfMetric: #FMeasure on: resCommitRandom))."
			(#precisionFineGrainedWeightedMean -> (self calculateFineGrainedWeightedMeanOfMetric: #Precision on: resMethod)).
			(#recallFineGrainedWeightedMean -> (self calculateFineGrainedWeightedMeanOfMetric: #Recall on: resMethod)).
			(#fmeasureFineGrainedWeightedMean -> (self calculateFineGrainedWeightedMeanOfMetric: #FMeasure on: resMethod)).
			"(#recallWeightedCommitNotNull -> (self calculateCommitNotNullWeightedMeanOfMetric: #Recall on: resMethod)).
			(#precisionWeightedCommitNotNull -> (self calculateCommitNotNullWeightedMeanOfMetric: #Precision on: resMethod))."
			(#data -> resMethod).
			(#dataCommit -> resCommit).
			(#gainData -> gainData first).
			(#gainCommitData -> gainCommit first).
			(#gainCommit -> gainCommit second).
			(#gain -> gainData second).
			(#gainFineGrainedWeightedMean -> (self calculateFineGrainedWeightedGainDataOn: resMethod)).
			(#percentageOfGreenTests -> ((greenTests occurrencesOf: 'pass') / greenTests size) asFloat)} asDictionary
]

{ #category : #accessing }
JacocoStats >> toRemove [
	^ [ :e | (self shouldRemoveSpecificly: e) or: [ e testIsGreen not ] ]
]
