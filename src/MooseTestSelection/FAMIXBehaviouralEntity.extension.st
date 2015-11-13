Extension { #name : #FAMIXBehaviouralEntity }

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> allIncomingInvocations [
	^ self deepCollect: [ :entity | entity incomingInvocations collect: [ :inv | inv from ] ]
]

{ #category : #'*MooseTestSelection-Experiments' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWith: selectors [
	| res |
	res := {self}
		deepCollect:
			[ :entity | 
			| duplicatedEntities |
			duplicatedEntities := entity duplicatedEntities.
			duplicatedEntities flatCollect: [ :aDuplicatedEntity | selectors collect: [ :aSelector | aDuplicatedEntity perform: aSelector ] ] ].
	^ res
]

{ #category : #'*MooseTestSelection-Experiments' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCalls [
	^ self allIncomingInvocationsWith: {#withIncomingInvocationsAndAccessCalls}
]

{ #category : #'*MooseTestSelection-Experiments' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCallsAndInner [
	^ self allIncomingInvocationsWith: #(#withInnerclassDefiningMethods  #withIncomingInvocationsAndAccessCalls)
]

{ #category : #'*MooseTestSelection-Experiments' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritance [
	^ self
		allIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withImplementMethods)
]

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables [
	^ self
		allIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withCallables #withImplementMethods)
]

{ #category : #'*MooseTestSelection-Experiments' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithCallable [
	^ self allIncomingInvocationsWith: {#withCallables. #withIncommingInvocations}
]

{ #category : #'*MooseTestSelection-Experiments' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithInnerclassDefiningMethods [
	^ self allIncomingInvocationsWith: #(#withInnerclassDefiningMethods withIncommingInvocations)
]

{ #category : #'*MooseTestSelection-Experiments' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithInterfacesCalls [
	^ self allIncomingInvocationsWith: {#withImplementMethods. #withIncommingInvocations}
]

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> allOutgoingInvocations [
	^ self deepCollect: [ :entity | entity outgoingInvocations collect: [ :inv | inv to ] ]
]

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> findRelatedAttributeCommingFrom: aMethod [
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

{ #category : #'*MooseTestSelection-TestImpl' }
FAMIXBehaviouralEntity >> isIgnored [
	<MSEProperty: #isIgnored type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment:
		'If the method is a test, it can be annotated with Ignore, the test is Bypassed'>
	^ "self privateState
		attributeAt: #isIgnored
		ifAbsentPut: [ "self isAnnotatedWith: 'Ignore' "]"
]

{ #category : #'*MooseTestSelection-TestImpl' }
FAMIXBehaviouralEntity >> isNotIgnoredTest [
	<MSEProperty: #isNotIgnoredTest type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment: 'If the method is a not ignored test'>
	^ self isTest and: [ self isIgnored not ]
]

{ #category : #'*MooseTestSelection-TestImpl' }
FAMIXBehaviouralEntity >> isTest [
	<MSEProperty: #isTest type: #Boolean>
	<derived>
	<MSEComment: 'If the method is a test'>
	^ self isJUnit4Test
]

{ #category : #'*MooseTestSelection-TestImpl' }
FAMIXBehaviouralEntity >> overridedMethods [
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

{ #category : #'*MooseTestSelection-TestImpl' }
FAMIXBehaviouralEntity >> overridesMethod [
	^ (self belongsTo superclassHierarchy "reject: #isInterface")
		collect: [ :each | each implementationOf: self signature ] thenSelect: #isNotNil
]

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> withCallables [
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

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> withImplementMethods [
	"or overriding"

	^ (OrderedCollection new
		add: self;
		addAll: self overridesMethod;
		yourself) select: #isNotNil
]

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> withIncomingInvocationsAndAccessCalls [
	| invocationContainers foundAccesses |
	invocationContainers := self withIncommingInvocations.
	foundAccesses := invocationContainers
		flatCollect:
			[ :invocationContainer | 
			(invocationContainer findRelatedAttributeCommingFrom: self)
				collect: [ :e | e incomingAccesses collect: #from ] ].
	^ invocationContainers , foundAccesses select: #isNotNil
]

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> withIncommingInvocations [
	^ self incomingInvocations collect: #from.
]

{ #category : #'*MooseTestSelection' }
FAMIXBehaviouralEntity >> withInnerclassDefiningMethods [
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
