Extension { #name : #FAMIXBehaviouralEntity }

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> addCoveredByJacocoTestClass: aFAMIXClass [ 
	self coveredByJacocoTestMethods add: aFAMIXClass 
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocations [
	^ self deepCollect: [ :entity | entity incomingInvocations collect: [ :inv | inv from ] ]
]

{ #category : #'*Jacoco-Import - static' }
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

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCalls [
	^ self allIncomingInvocationsWith: {#withIncomingInvocationsAndAccessCalls}
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCallsAndInner [
	^ self allIncomingInvocationsWith: #(#withInnerclassDefiningMethods  #withIncomingInvocationsAndAccessCalls)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritance [
	^ self
		allIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withImplementMethods)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables [
	^ self
		allIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withCallables #withImplementMethods)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithCallable [
	^ self allIncomingInvocationsWith: {#withCallables. #withIncommingInvocations}
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithInnerclassDefiningMethods [
	^ self allIncomingInvocationsWith: #(#withInnerclassDefiningMethods withIncommingInvocations)
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allIncomingInvocationsWithInterfacesCalls [
	^ self allIncomingInvocationsWith: {#withImplementMethods. #withIncommingInvocations}
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allNumerotedIncomingInvocationsWith: selectors [
	| res count |
	count := 0.
	res := {self}
		deepCollect:
			[ :entity | 
			| duplicatedEntities |
			duplicatedEntities := entity duplicatedEntities.
			count := count + 1.
			duplicatedEntities
				flatCollect:
					[ :aDuplicatedEntity | 
					selectors
						collect: [ :aSelector | 
							aDuplicatedEntity privateState propertyAt: #count ifAbsentPut: [ count ].
							aDuplicatedEntity perform: aSelector ] ] ].
	^ res
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> allNumerotedIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables [
	^ self
		allNumerotedIncomingInvocationsWith:
			#(#withInnerclassDefiningMethods #withIncomingInvocationsAndAccessCalls #withCallables #withImplementMethods)
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> coverJacocoMethods [
	<MSEProperty: #coverJacocoMethods type: #FAMIXMethod opposite: #coveredByJacocoTestMethods>
	<multivalued>
	<MSEComment: 'Methods that are covered by this test case'>
	^ self privateState
		attributeAt: #coverJacocoMethods
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coveredByJacocoTestMethods ]
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> coverJacocoMethods: aCollection [
	self coverJacocoMethods values: aCollection
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> coveredByJacocoTestMethods [
	<MSEProperty: #coveredByJacocoTestMethods type: #FAMIXMethod opposite: #coverJacocoMethods>
	<multivalued>
	<MSEComment: 'Methods whose tests cover this method'>
	^ self privateState
		attributeAt: #coveredByJacocoTestMethods
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coverJacocoMethods ]
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> coveredByTestClassesWithoutSomeClasses [

	^ self coveredByJacocoTestMethods reject: [ :c | c mooseName = 'net::atos::wlp::cedicam::AbstractTest' ]
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> duplicatedEntities [
	^ (self mooseModel allModelClassesAndInterfacesWithDuplicatedMethods
		includes: self belongsTo)
		ifTrue:
			[ self belongsTo methods select: [ :m | m signature = self signature ] ]
		ifFalse: [ {self} ]
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> isCallingCoveredTestsClasses [
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
FAMIXBehaviouralEntity >> isCallingTestsClasses [
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
FAMIXBehaviouralEntity >> isCoveredByJacocoTestMethods [
	<MSEProperty: #isCoveredByJacocoTestMethods type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment: 'If the method is covered by tests'>
	^ self coveredByJacocoTestMethods isNotEmpty
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> isCoveredByJacocoTestMethodsByRejecting: aBlock [
	^ (self coveredByJacocoTestMethods reject: aBlock) isNotEmpty
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> isCoveringJacocoMethods [
	<MSEProperty: #isCoveringJacocoMethods type: #Boolean>
	<multivalued>
	<MSEComment: 'True is the method covers methods'>
	^ self coverJacocoMethods isNotEmpty
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> matchWithJacocoDescription: aJacocoDescription [
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

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> numberOfArgsFromSignature [
	<MSEProperty: #numberOfArgsFromSignature type: #Number>
	<MSEComment: 'numberOfArgsFromSignature'>
	
	| cut args |
	cut := self signature substrings: '('.
	args := cut second allButLast substrings: ','.
	"Just  good to have the number of args. 
	Ex :  'createPersistenceXml(Map<String,String>)'
	"
	
	^ args size - (cut second occurrencesOf: $<)
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundAnyTestMethodsCallingMyself [
	^ (self
		deepCollect: [ :entity | 
			entity incomingInvocations
				collect: [ :inv | 
					inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
				thenSelect: #isNotNil ]) select: #isTest
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundByClassJacocoTestMethodsCallingMyself [
	^ ((self
		deepCollect:
			[ :entity | (entity queryAllIncomingInvocations " MooseChef FAMIXInvocation") atTypeScope "FAMIXClass" ])
		flatCollect: [ :e | e methods ])
		select: #isCoveringJacocoMethods
	", {self}: not added because only the core is managed"
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyself [
	^ ((self
		deepCollect: [ :entity | 
			entity incomingInvocations
				collect: [ :inv | 
					inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
				thenSelect: #isNotNil ]), { self } ) select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccess [
	^ self allIncomingInvocationsWithAccessCalls , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInner [
	^ self allIncomingInvocationsWithAccessCallsAndInner , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritance [
	^ self allIncomingInvocationsWithAccessCallsAndInnerAndInheritance , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritanceAndCallable [
	^ self allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingCallable [
	^ self allIncomingInvocationsWithCallable , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInheritance [
	^ self allIncomingInvocationsWithInterfacesCalls , {self} select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInnerclasses [
	^ (self allIncomingInvocationsWithInnerclassDefiningMethods, {self}) select: #isCoveringJacocoMethods
]
