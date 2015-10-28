Extension { #name : #FAMIXMethod }

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> addCoveredByJacocoTestClass: aFAMIXClass [ 
	self coveredByJacocoTestMethods add: aFAMIXClass 
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocations [
	^ self deepCollect: [ :entity | entity incomingInvocations collect: [ :inv | inv from ] ]
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWith: selectors [
	| res |
	res := {self}
		deepCollect:
			[ :entity | 
			| duplicatedEntities |
			duplicatedEntities := entity duplicatedEntities.
			duplicatedEntities
				flatCollect:
					[ :aDuplicatedEntity | selectors collect: [ :aSelector | aDuplicatedEntity perform: aSelector ] ] ].
	^ res
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithAccessCalls [
	^ self allIncomingInvocationsWith: {#withIncomingInvocationsAndAccessCalls}
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithAccessCallsAndInner [
	^ self allIncomingInvocationsWith: #(#withInnerclassDefiningMethods  #withIncomingInvocationsAndAccessCalls)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritance [
	^ self
		allIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withImplementMethods)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables [
	^ self
		allIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withCallables #withImplementMethods)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithCallable [
	^ self allIncomingInvocationsWith: {#withCallables. #withIncommingInvocations}
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithInnerclassDefiningMethods [
	^ self allIncomingInvocationsWith: #(#withInnerclassDefiningMethods withIncommingInvocations)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithInterfacesCalls [
	^ self allIncomingInvocationsWith: {#withImplementMethods. #withIncommingInvocations}
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allOutgoingInvocations [
	^ self deepCollect: [ :entity | entity outgoingInvocations collect: [ :inv | inv to ] ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coverJacocoMethods [
	<MSEProperty: #coverJacocoMethods type: #FAMIXMethod opposite: #coveredByJacocoTestMethods>
	<multivalued>
	<MSEComment: 'Methods that are covered by this test case'>
	^ self privateState
		attributeAt: #coverJacocoMethods
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coveredByJacocoTestMethods ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coverJacocoMethods: aCollection [
	self coverJacocoMethods values: aCollection
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coveredByJacocoTestMethods [
	<MSEProperty: #coveredByJacocoTestMethods type: #FAMIXMethod opposite: #coverJacocoMethods>
	<multivalued>
	<MSEComment: 'Methods whose tests cover this method'>
	^ self privateState
		attributeAt: #coveredByJacocoTestMethods
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coverJacocoMethods ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coveredByTestClassesWithoutSomeClasses [

	^ self coveredByJacocoTestMethods reject: [ :c | c mooseName = 'net::atos::wlp::cedicam::AbstractTest' ]
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> findRelatedAttributeCommingFrom: aMethod [
	| class attributes declaredTypeOfTheMethodReturn |
	^ self name = '<Initializer>'
		ifTrue:
			[ class := self belongsTo.
			declaredTypeOfTheMethodReturn := aMethod isConstructor
				ifTrue: [ aMethod belongsTo ]
				ifFalse: [ aMethod declaredType ].
			attributes := class attributes
				select:
					[ :attribute | 
					"self halt.
					attribute declaredType isStub
						ifTrue: [  ]
						ifFalse:
							[ "declaredTypeOfTheMethodReturn withSuperclassHierarchy
								includes: attribute declaredType ] "]".
			attributes
				ifEmpty:
					[ self sourceAnchor
						ifNotNil:
							[ {self.
							aMethod} asLog
								tag: 'findRelatedAttributeCommingFrom-empty';
								emit.
							^ {} ]
						ifNil: [ "self notYetImplemented" ] ].
			attributes size = 1
				ifFalse:
					[ {self.
					aMethod} asLog
						tag: 'findRelatedAttributeCommingFrom-sup1';
						emit ].
			attributes ]
		ifFalse: [ {} ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> isCallingCoveredTestsClasses [
	^ (self
		deepCollect: [ :entity | 
			entity incomingInvocations
				collect: [ :inv | 
					inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
				thenSelect: #isNotNil ]) anySatisfy: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> isCallingTestsClasses [
	^ (self
		deepCollect: [ :entity | 
			entity incomingInvocations
				collect: [ :inv | 
					inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
				thenSelect: #isNotNil ]) anySatisfy: #isTest
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> isCoveredByJacocoTestMethods [
	<MSEProperty: #isCoveredByJacocoTestMethods type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment: 'If the method is covered by tests'>
	^ self coveredByJacocoTestMethods isNotEmpty
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> isCoveredByJacocoTestMethodsByRejecting: aBlock [
	^ (self coveredByJacocoTestMethods reject: aBlock) isNotEmpty
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> isCoveringJacocoMethods [
	<MSEProperty: #isCoveringJacocoMethods type: #Boolean>
	<multivalued>
	<MSEComment: 'True is the method covers methods'>
	^ self coverJacocoMethods isNotEmpty
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isIgnored [
	<MSEProperty: #isIgnored type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment:
		'If the method is a test, it can be annotated with Ignore, the test is Bypassed'>
	^ "self privateState
		attributeAt: #isIgnored
		ifAbsentPut: [ "self isAnnotatedWith: 'Ignore' "]"
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isNotIgnoredTest [
	<MSEProperty: #isNotIgnoredTest type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment: 'If the method is a not ignored test'>
	^ self isTest and: [ self isIgnored not ]
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isTest [
	<MSEProperty: #isTest type: #Boolean>
	<derived>
	<MSEComment: 'If the method is a test'>
	^ self isJUnit4Test
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> matchWithJacocoDescription: aJacocoDescription [
	| returnValue selfArguments jacocoArgs jacocoArgsTypes return |
	{self signature.aJacocoDescription}.
	returnValue := aJacocoDescription first.
	jacocoArgs := aJacocoDescription allButFirst.
	"self parameters ifNotEmpty: [ self halt ]."
	selfArguments := (self signature substrings: '(') second allButLast.
	(selfArguments substrings: ',') collect: #asLowercase.
	jacocoArgsTypes := jacocoArgs
		collect: [ :i | (i substrings: '/') last asLowercase ].
	return := jacocoArgsTypes
		= ((selfArguments substrings: ',') collect: #asLowercase).

	^ return
]

{ #category : #'*Jacoco-Import temp to migrate to moose' }
FAMIXMethod >> overridedMethods [
	<MSEProperty: #overridedMethods type: #FAMIXMethod>
	<derived>
	<MSEComment:
		'The methods that are overrided by this method. I.e. the methods of the superclasses'>
	self flag: 'Add a test!'.
	^ (self belongsTo directSuperclasses
		select:
			[ :each | each isInterface not and: [ each understands: self signature ] ]
		thenCollect: [ :each | each methodsUnderstanding: self signature ]) flatten
]

{ #category : #'*Jacoco-Import temp to migrate to moose' }
FAMIXMethod >> overridesMethod [
	^ (self belongsTo superclassHierarchy "reject: #isInterface")
		collect: [ :each | each implementationOf: self signature ] thenSelect: #isNotNil
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundAnyTestMethodsCallingMyself [
	^ (self
		deepCollect: [ :entity | 
			entity incomingInvocations
				collect: [ :inv | 
					inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
				thenSelect: #isNotNil ]) select: #isTest
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundByClassJacocoTestMethodsCallingMyself [
	^ ((self
		deepCollect:
			[ :entity | (entity queryAllIncomingInvocations " MooseChef FAMIXInvocation") atTypeScope "FAMIXClass" ])
		flatCollect: [ :e | e methods ])
		select: #isCoveringJacocoMethods
	", {self}: not added because only the core is managed"
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyself [
	^ ((self
		deepCollect: [ :entity | 
			entity incomingInvocations
				collect: [ :inv | 
					inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
				thenSelect: #isNotNil ]), { self } ) select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccess [
	^ self allIncomingInvocationsWithAccessCalls , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInner [
	^ self allIncomingInvocationsWithAccessCallsAndInner , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritance [
	^ self allIncomingInvocationsWithAccessCallsAndInnerAndInheritance , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritanceAndCallable [
	^ self allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingCallable [
	^ self allIncomingInvocationsWithCallable , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInheritance [
	^ self allIncomingInvocationsWithInterfacesCalls , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInnerclasses [
	^ (self allIncomingInvocationsWithInnerclassDefiningMethods, {self}) select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withCallables [
	"or overriding"

	| return constructor |
	return := OrderedCollection new
		add: self;
		yourself.
	self signature = 'call()'
		ifTrue:
			[ self
				assert: (self belongsTo directSuperclasses anySatisfy: [ :e | e name = 'Callable' ]).
			constructor := self belongsTo methods
				select: [ :m | m isConstructor or: [ m name endsWith: '.' , m belongsTo name ] ].
			"self assert: constructor size = 1."
			constructor size = 1
				ifFalse: [ ^ return select: #isNotNil ].
			return addAll: constructor first allIncomingInvocations ].
	^ return select: #isNotNil
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withImplementMethods [
	"or overriding"

	^ (OrderedCollection new
		add: self;
		addAll: self overridesMethod;
		yourself) select: #isNotNil
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withIncomingInvocationsAndAccessCalls [
	| invocationContainers foundAccesses |
	invocationContainers := self withIncommingInvocations.
	foundAccesses := invocationContainers
		flatCollect:
			[ :invocationContainer | 
			(invocationContainer findRelatedAttributeCommingFrom: self)
				collect: [ :e | e incomingAccesses collect: #from ] ].
	^ invocationContainers , foundAccesses select: #isNotNil
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withIncommingInvocations [
	^ self incomingInvocations collect: #from.
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withInnerclassDefiningMethods [
	| res |

	res := OrderedCollection with: self.
	self belongsTo isInnerClass
		ifTrue:
			[ "{self belongsTo.
			self mooseName} asLog
				tag: 'withInnerclassDefiningMethods';
				emit."
			self belongsTo belongsTo isMethod
				ifTrue:
					[ res add: self belongsTo belongsTo.
					res
						addAll: self belongsTo belongsTo withInnerclassDefiningMethods ] ].
	^ res
]
