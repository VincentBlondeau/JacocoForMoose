Extension { #name : #FAMIXMethod }

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> hasAnXMLReportFromJacoco [
	^ self privateState attributeAt: #hasAnXMLReportFromJacoco ifAbsent: [ false ]
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> hasAnXMLReportFromJacoco: aBoolean [
	self privateState attributeAt: #hasAnXMLReportFromJacoco put: aBoolean
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

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> isInStaticPartOfTheInitializerCommingFrom: aMethod [
	| class attributes declaredTypeOfTheMethodReturn |
	class := self belongsTo.
	declaredTypeOfTheMethodReturn := aMethod isConstructor
		ifTrue: [ aMethod belongsTo ]
		ifFalse: [ aMethod declaredType ].
	attributes := class attributes
		select:
			[ :attribute | declaredTypeOfTheMethodReturn withSuperclassHierarchy includes: attribute declaredType ].
	attributes
		ifEmpty:
			[ self sourceAnchor
				ifNotNil:
					[ ^ self hasClassScope
						ifFalse: [ self notYetImplemented ]
						ifTrue: [ self hasClassScope ] ]
				ifNil: [ ^ class attributes anySatisfy: [ :attr | attr hasClassScope ] ]	"cas où l'appel n'est pas directement affecté à l'attribut" ].
	attributes size = 1
		ifFalse:
			[ Log
				warn:
					{'[JacocoStats] More than one attribute found'.
					self.
					aMethod} ].
	^ attributes anySatisfy: [ :attr | attr hasClassScope ]
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isMethodAnchorInTheCoreDir [
	self flag: 'SHOULD NOT BE USED FOR JACOCOStats'.
	^ self sourceAnchor
		ifNil: [ self belongsTo sourceAnchor fileName includesSubstring: 'src/main' ]
		ifNotNil: [ :sa | sa fileName includesSubstring: 'src/main' ]
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
			invocationContainer name = '<Initializer>'
				ifFalse: [ {} ]
				ifTrue:
					[ (invocationContainer
						isInStaticPartOfTheInitializerCommingFrom: self)
						ifTrue:
							[ Log
								info:
									{'static'.
									self.
									invocationContainer belongsTo queryAllIncomingAssociations
										opposites reject: #isClass}.
							invocationContainer belongsTo queryAllIncomingAssociations
								opposites reject: #isClass	"Static" ]
						ifFalse:
							[ Log
								info:
									{'not static'.
									self.
									(self belongsTo constructors
										flatCollect: [ :m | m invokingBehaviours ])}.
							self belongsTo constructors
								flatCollect: [ :m | m invokingBehaviours ]	"queryIncoming: FAMIXInvocation)
								opposites	"	"not static" ]	"self halt."	"self halt. " ] ].
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
