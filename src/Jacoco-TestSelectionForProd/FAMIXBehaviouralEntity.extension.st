Extension { #name : #FAMIXBehaviouralEntity }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWith: selectors [
	| res |
	res := {self}
		deepCollect:
			[ :entity | 
			| duplicatedEntities |
			duplicatedEntities := entity duplicatedEntities.
			duplicatedEntities
				flatCollect:
					[ :aDuplicatedEntity | 
					selectors
						collect: [ :aSelector | aDuplicatedEntity perform: aSelector ] ] ].
	^ res
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables [
	^ self
		allIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withCallables #withImplementMethods #withBeforeAnnotations)
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> duplicatedEntities [
	^ (self mooseModel allModelClassesAndInterfacesWithDuplicatedMethods includes: self belongsTo)
		ifTrue: [ self belongsTo methods select: [ :m | m signature = self signature ] ]
		ifFalse: [ {self} ]
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> isInStaticPartOfTheInitializerCommingFrom: aMethod [
	| belongsTo collectionOfPotentialAttributes methodContainer |
	belongsTo := self belongsTo.
	methodContainer := aMethod isConstructor
		ifTrue: [ aMethod belongsTo ]
		ifFalse: [ aMethod declaredType ].
	collectionOfPotentialAttributes := belongsTo attributes
		select:
			[ :att | methodContainer withSuperclassHierarchy includes: att declaredType ].
	collectionOfPotentialAttributes
		ifEmpty:
			[ self sourceAnchor ifNotNil: [ ^ true ].
			^ belongsTo attributes anySatisfy: [ :att | att hasClassScope ] ].
	collectionOfPotentialAttributes size = 1
		ifFalse:
			[ Log
				warn:
					{'[JacocoStats] More than one attribute found'.
					self.
					aMethod} ].
	^ collectionOfPotentialAttributes anySatisfy: [ :att | att hasClassScope ]
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> retrieveTests [
	^ (OrderedCollection with: self)
		addAll: self allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables;
		yourself
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> withBeforeAnnotations [
	"@Before -> Select @Test methods of current and all subclasses"

	| res |
	res := OrderedCollection new.
	(self isAnnotatedWith: 'Before')
		ifTrue: [ self belongsTo withSubclassesDo: [ :subclass | res addAll: subclass allTestMethods ] ].
	^ res select: #isNotNil
]

{ #category : #'*Jacoco-TestSelectionForProd' }
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

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> withImplementMethods [
	"or overriding"

	^ (OrderedCollection new
		add: self;
		addAll: self overridesMethod;
		yourself) select: #isNotNil
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> withIncomingInvocationsAndAccessCalls [
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

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> withIncommingInvocations [
	^ self incomingInvocations collect: #from
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> withInnerclassDefiningMethods [
	| res |
	res := OrderedCollection with: self.
	self belongsTo ifNil: [ ^ res ].
	self belongsTo isInnerClass
		ifTrue: [ "{self belongsTo.
			self mooseName} asLog
				tag: 'withInnerclassDefiningMethods';
				emit."
			self belongsTo belongsTo isMethod
				ifTrue: [ res add: self belongsTo belongsTo.
					res addAll: self belongsTo belongsTo withInnerclassDefiningMethods ] ].
	^ res
]
