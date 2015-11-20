Extension { #name : #FAMIXMethod }

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

{ #category : #'*Jacoco-Import temp to migrate to moose' }
FAMIXMethod >> overridesMethod [
	^ (self belongsTo superclassHierarchy "reject: #isInterface")
		collect: [ :each | each implementationOf: self signature ] thenSelect: #isNotNil
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
