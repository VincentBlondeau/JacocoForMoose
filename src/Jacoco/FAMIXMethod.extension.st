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
FAMIXMethod >> allIncomingInvocationsWith: aSelector [
	^ (self perform: aSelector withEnoughArguments: {self})
		deepCollect:
			[ :entity | (entity incomingInvocations collect: [ :inv | inv from perform: aSelector withEnoughArguments:  {entity} ]) flatten ]
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithAccessCalls [
	^ self allIncomingInvocationsWith: #withAccessCalls:
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithAccessCallsAndInner [
	^ self allIncomingInvocationsWith: #withAccessCallsAndInner:
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritance [
	^ self allIncomingInvocationsWith: #withAccessCallsAndInnerAndInheritance:
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithInnerclassDefiningMethods [
	^ self allIncomingInvocationsWith: #withInnerclassDefiningMethods
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocationsWithInterfacesCalls [
	^ self allIncomingInvocationsWith: #withImplementMethods
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
					[ :attribute | declaredTypeOfTheMethodReturn withSuperclassHierarchy includes: attribute declaredType ].
			attributes
				ifEmpty:
					[ self sourceAnchor
						ifNotNil: [ {self.
							aMethod} asLog
								tag: 'findRelatedAttributeCommingFrom';
								emit.
							^ {} ]
						ifNil: [ self notYetImplemented ] ].
			self assert: attributes size = 1.
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
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInheritance [
	^ self allIncomingInvocationsWithInterfacesCalls , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInnerclasses [
	^ (self allIncomingInvocationsWithInnerclassDefiningMethods, {self}) select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withAccessCalls: theOriginalEntity [
	^ (OrderedCollection new
		add: self;
		addAll:
			((self findRelatedAttributeCommingFrom: theOriginalEntity)
				collect: [ :e | e incomingAccesses collect: #from ]);
		yourself) select: #isNotNil
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withAccessCallsAndInner: theOriginalEntity [
	^ (self withInnerclassDefiningMethods , (self withAccessCalls: theOriginalEntity )) asSet
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withAccessCallsAndInnerAndInheritance: theOriginalEntity [
	^ (self withInnerclassDefiningMethods , (self withAccessCalls: theOriginalEntity) , self withImplementMethods) asSet
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
FAMIXMethod >> withInnerclassDefiningMethods [
	| res |
	res := OrderedCollection with: self.
	self belongsTo isInnerClass
		ifTrue:
			[ {self belongsTo.
			self mooseName} asLog
				tag: 'withInnerclassDefiningMethods';
				emit.
			self belongsTo belongsTo isMethod
				ifTrue:
					[ res add: self belongsTo belongsTo.
					res
						addAll: self belongsTo belongsTo withInnerclassDefiningMethods ] ].
	^ res
]
