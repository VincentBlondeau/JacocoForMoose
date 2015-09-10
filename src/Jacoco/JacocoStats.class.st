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
	#category : #Jacoco
}

{ #category : #stats }
JacocoStats >> basicRun [
	^ self statsOn: self model
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
JacocoStats >> calculatePrecisionMeanOn: res [
	| elements |
	elements := res
		collect: [ :e | self calculatePrecisionOn: e ]
		thenReject: #isNil.
	^ elements asOrderedCollection average
]

{ #category : #'metrics calculus' }
JacocoStats >> calculatePrecisionOn: aDictionary [
	| tp fp |
	tp := aDictionary at: #tp.
	fp := aDictionary at: #fp.
	^ tp size + fp size = 0
		ifTrue: [ nil ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fp size asFloat) ]
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateRecallMeanOn: res [
		| elements |
	elements := res
		collect: [ :e | self calculateRecallOn: e ]
		thenReject: #isNil.
	^ elements asOrderedCollection average
]

{ #category : #'metrics calculus' }
JacocoStats >> calculateRecallOn: aDictionary [
	| tp fn |
	tp := aDictionary at: #tp.
	fn := aDictionary at: #fn.
	^ tp size + fn size = 0
		ifTrue: [ nil ]
		ifFalse: [ tp size asFloat / (tp size asFloat + fn size asFloat) ]
]

{ #category : #'stats - making' }
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
	(#jacoco -> realData)	.
	(#greenTests -> (realData collect: #testStatus) )
		".
	(#tn -> tn)"} asDictionary
]

{ #category : #'stats - making' }
JacocoStats >> makeInfinitestStatsOn: method [
	| positives realData |
	positives := method staticlyFoundInfinitestTestMethodsCallingMyself reject: self toRemove.
	"all := method staticlyFoundAnyTestMethodsCallingMyself."
	realData := self selectMethodsCovering: method.
	^ self
		createDictionaryForMethod: method
		fromPostives: positives
		realData: realData
		all: nil
]

{ #category : #'stats - making' }
JacocoStats >> makeStaticCallAndAccessAndInheritanceStatsOn: method [
	| positives realData |
	positives := method
		staticlyFoundJacocoTestMethodsCallingMyselfUsingNotOnlyAccesses
		reject: self toRemove.
	realData := self selectMethodsCovering: method.
	^ self
		createDictionaryForMethod: method
		fromPostives: positives
		realData: realData
		all: nil
]

{ #category : #'stats - making' }
JacocoStats >> makeStaticClassStatsOn: method [
	| positives realData |
	positives := method staticlyFoundByClassJacocoTestMethodsCallingMyself reject: self toRemove.
	realData := self selectMethodsCovering: method.
	"all := method staticlyFoundAnyTestMethodsCallingMyself."
	^ self
		createDictionaryForMethod: method
		fromPostives: positives
		realData: realData
		all: nil
]

{ #category : #'stats - making' }
JacocoStats >> makeStaticInnerclassesStatsOn: method [
	| positives realData |
	positives := method staticlyFoundJacocoTestMethodsCallingMyselfUsingInnerclasses reject: self toRemove.
	realData := self selectMethodsCovering: method.
	"all := method staticlyFoundAnyTestMethodsCallingMyself."
	^ self
		createDictionaryForMethod: method
		fromPostives: positives
		realData: realData
		all: nil
]

{ #category : #'stats - making' }
JacocoStats >> makeStaticStatsOn: method [
	| positives realData |
	positives := method staticlyFoundJacocoTestMethodsCallingMyself
		reject: self toRemove.
	realData := self selectMethodsCovering: method.
	"all := method staticlyFoundAnyTestMethodsCallingMyself."
	^ self
		createDictionaryForMethod: method
		fromPostives: positives
		realData: realData
		all: nil
]

{ #category : #accessing }
JacocoStats >> numberOfTestsMethodsFromModel: aMooseModel [
	^ (((self model allModelMethods reject: [ :e | e isStub ])
		select:
			[ :m | 
			(m sourceAnchor
				ifNil: [ m belongsTo sourceAnchor fileName beginsWith: './wlp-cms-core/src/test' ]
				ifNotNil: [ :sa | sa fileName beginsWith: './wlp-cms-core/src/test' ]) and: [ m isCoveringJacocoMethods ] ]) reject: self toRemove) size
]

{ #category : #accessing }
JacocoStats >> selectMethodsCovering: method [
	^ (method coveredByJacocoTestMethods select: [ :m | m isNotIgnoredTest ])
		reject: self toRemove
]

{ #category : #accessing }
JacocoStats >> selectMethodsFromModel: aMooseModel [
	^ (aMooseModel allModelMethods reject: [ :e | e isStub ])
		select:
			[ :m | 
			(m sourceAnchor
				ifNil: [ m belongsTo sourceAnchor fileName beginsWith: './wlp-cms-core/src/main' ]
				ifNotNil: [ :sa | sa fileName beginsWith: './wlp-cms-core/src/main' ])
				and: [ m isCoveredByJacocoTestMethodsByRejecting: self toRemove ] ]
]

{ #category : #halting }
JacocoStats >> shouldHalt [
	index ifNil: [ index := 0 ].
	self crLog: index.
	index := index + 1.
	Halt onCount: 1000
]

{ #category : #stats }
JacocoStats >> statsOn: aMooseModel [
	^ {(self statsOn: aMooseModel methodSelector: #makeInfinitestStatsOn: dicoEntry: #jacocoVSInfinitest).
	(self statsOn: aMooseModel methodSelector: #makeStaticStatsOn: dicoEntry: #jacocoVSStatic).
	(self statsOn: aMooseModel methodSelector: #makeStaticCallAndAccessAndInheritanceStatsOn: dicoEntry: #jacocoVSStaticWithInheritance).
	(self statsOn: aMooseModel methodSelector: #makeStaticClassStatsOn: dicoEntry: #jacocoVSStaticClass).
	(self statsOn: aMooseModel methodSelector: #makeStaticInnerclassesStatsOn: dicoEntry: #jacocoVSStaticWithInner)} asDictionary
]

{ #category : #stats }
JacocoStats >> statsOn: aMooseModel methodSelector: aMethodSelector dicoEntry: dicoEntry [
	| precisionMean recallMean res methods gainData greenTests |
	methods := self selectMethodsFromModel: aMooseModel.
	res := methods
		collect: [ :m | self perform: aMethodSelector with: m ].
	precisionMean := self calculatePrecisionMeanOn: res.
	recallMean := self calculateRecallMeanOn: res.
	gainData := self calculateGainDataOn: res.
	greenTests := res flatCollect: [ :e | e at: #greenTests ].
	^ dicoEntry
		->
			{(#recall -> recallMean).
			(#precision -> precisionMean).
			(#data -> res).
			(#gainData -> gainData first).
			(#gain -> gainData second).
			(#percentageOfGreenTests
				->
					((greenTests occurrencesOf: 'pass') / greenTests size) asFloat)}
				asDictionary
]

{ #category : #accessing }
JacocoStats >> testGetterSetter [
	^ testGetterSetter ifNil: [ testGetterSetter := self model testGetterSetter ]
]

{ #category : #accessing }
JacocoStats >> toRemove [
	^ [ :e | e = self model testGetterSetter or: [ e testIsGreen not ] ]
]
