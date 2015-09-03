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
FAMIXMethod >> allIncomingInvocationsWithInterfacesCalls [
	^ self withImplementMethods deepCollect: [ :entity | (entity incomingInvocations collect: [ :inv | inv from withImplementMethods ]) flatten ]
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allOutgoingInvocations [
	^ self deepCollect: [ :entity | entity outgoingInvocations collect: [ :inv | inv to ] ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coverJacocoMethods [
	<MSEProperty: #coverJacocoMethods type: #FAMIXMethod opposite: #coveredByJacocoTestMethods>
	<multivalued>
	<MSEComment: 'Methods that are covered by this class'>
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
FAMIXMethod >> staticlyFoundJacocoTestMethodsCallingMyselfUsingNotOnlyAccesses [

"((self accesses collect: [ :access | access to  incomingAccesses collect: #from ] ) flatten collect: #allIncomingInvocations ) flatten."

"self implementMethod collect: #allIncomingInvocations.
	self haltIf: [ self accesses isNotEmpty ]."
	^ (self allIncomingInvocationsWithInterfacesCalls, {self}) select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> withImplementMethods [
	^ (self isImplementing
		ifFalse: [ {self} ]
		ifTrue:
			[ 
			OrderedCollection new
				add: self;
				addAll: self implementMethod;
				yourself ]) select: #isNotNil
]
