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

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXBehaviouralEntity >> duplicatedEntities [
	^ self privateState
		cacheAt: #duplicatedEntities
		ifAbsentPut:
			[ (self mooseModel allModelClassesAndInterfacesWithDuplicatedMethods
				includes: self belongsTo)
				ifTrue:
					[ self belongsTo methods
						select: [ :m | m signature = self signature ] ]
				ifFalse: [ {self} ] ]
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
	^ self privateState
		cacheAt: #staticlyFoundAnyTestMethodsCallingMyself
		ifAbsentPut:
			[ (self
				deepCollect: [ :entity | 
					entity incomingInvocations
						collect: [ :inv | 
							inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
						thenSelect: #isNotNil ]) select: #isTest ]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundByClassJacocoTestMethodsCallingMyself [
	^ self privateState
		cacheAt: #staticlyFoundByClassJacocoTestMethodsCallingMyself
		ifAbsentPut:
			[ ((self deepCollect: [ :entity | entity queryAllIncomingInvocations atTypeScope	" MooseChef FAMIXInvocation"	"FAMIXClass" ]) flatCollect: [ :e | e methods ]) select: #isCoveringJacocoMethods
			", {self}: not added because only the core is managed" ]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyself [
	^ self privateState
		cacheAt: #staticlyFoundJacocoTestMethodsCallingMyself
		ifAbsentPut:
			[ (self
				deepCollect: [ :entity | 
					entity incomingInvocations
						collect: [ :inv | 
							inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
						thenSelect: #isNotNil ]) , {self} select: #isCoveringJacocoMethods ]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccess [
	^ self privateState
		cacheAt:
			#staticlyFoundJacocoTestMethodsCallingMyselfUsingAccess
		ifAbsentPut:
			[ self allIncomingInvocationsWithAccessCalls , {self} select: #isCoveringJacocoMethods]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInner [
	^ self privateState
		cacheAt:
			#staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInner
		ifAbsentPut:
			[ self allIncomingInvocationsWithAccessCallsAndInner , {self}
				select: #isCoveringJacocoMethods ]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritance [
	^ self privateState
		cacheAt:
			#staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritance
		ifAbsentPut:
			[ self allIncomingInvocationsWithAccessCallsAndInnerAndInheritance
				, {self} select: #isCoveringJacocoMethods ]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritanceAndCallable [
	^ self privateState
		cacheAt:
			#staticlyFoundJacocoTestMethodsCallingMyselfUsingAccessAndInnerAndInheritanceAndCallable
		ifAbsentPut:
			[ self
				allIncomingInvocationsWithAccessCallsAndInnerAndInheritanceAndCallables
				, {self} select: #isCoveringJacocoMethods ]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingCallable [
^ self privateState
		cacheAt:
			#staticlyFoundJacocoTestMethodsCallingMyselfUsingCallable
		ifAbsentPut:
			[ self allIncomingInvocationsWithCallable , {self} select: #isCoveringJacocoMethods]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInheritance [
	^ self privateState
		cacheAt:
			#staticlyFoundJacocoTestMethodsCallingMyselfUsingInheritance
		ifAbsentPut:
			[  self allIncomingInvocationsWithInterfacesCalls , {self} select: #isCoveringJacocoMethods]
]

{ #category : #'*Jacoco-TestSelection' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestMethodsCallingMyselfUsingInnerclasses [
	^ self privateState
		cacheAt: #staticlyFoundJacocoTestMethodsCallingMyselfUsingInnerclasses
		ifAbsentPut: [ self allIncomingInvocationsWithInnerclassDefiningMethods , {self} select: #isCoveringJacocoMethods ]
]

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> staticlyFoundJacocoTestsAllClasses [
	^ self privateState
		cacheAt: #staticlyFoundJacocoTestsAllClasses
		ifAbsentPut:
			[ ((self belongsTo
				deepCollect:
					[ :entity | 
					| res query plop |
					query := Set new
						addAll: entity queryAllIncomingInvocations atTypeScope;
						addAll: entity queryIncomingAccesses atTypeScope;
						addAll: entity queryIncomingReferences atTypeScope;
						addAll: entity queryOutgoingInheritances atTypeScope;
						yourself.
					res := query asSet.
					plop := entity isMethod
						ifTrue: [ entity belongsTo ]
						ifFalse: [ entity ].
					plop isInnerClass
						ifTrue:
							[ entity belongsTo isMethod
								ifTrue: [ res add: entity belongsTo ] ].
					res ])
				flatCollect:
					[ :e | 
					e isMethod
						ifTrue: [ {e} ]
						ifFalse: [ e methods ] ]) select: #isCoveringJacocoMethods ]
]
