Extension { #name : #FAMIXMethod }

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> addCoveredByJacocoTestClass: aFAMIXClass [ 
	self coveredByJacocoTestClasses add: aFAMIXClass 
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allIncomingInvocations [
	^ self deepCollect: [ :entity | entity incomingInvocations collect: [ :inv | inv from ] ]
]

{ #category : #'*Jacoco-Import - static' }
FAMIXMethod >> allOutgoingInvocations [
	^ self deepCollect: [ :entity | entity outgoingInvocations collect: [ :inv | inv to ] ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> calledCoveredTestsClasses [
	^ (self
		deepCollect: [ :entity | 
			entity incomingInvocations
				collect: [ :inv | 
					inv from	"isStub
				ifFalse: [ inv from ]
				ifTrue: [ nil ] " ]
				thenSelect: #isNotNil ]) select: #isCoveringJacocoMethods
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> calledTestsClasses [
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
FAMIXMethod >> coverJacocoMethods [
	<MSEProperty: #coverJacocoMethods type: #FAMIXMethod opposite: #coveredByJacocoTestClasses>
	<multivalued>
	<MSEComment: 'Methods that are covered by this class'>
	^ self privateState
		attributeAt: #coverJacocoMethods
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coveredByJacocoTestClasses ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coverJacocoMethods: aCollection [
	self coverJacocoMethods values: aCollection
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coveredByJacocoTestClasses [
	<MSEProperty: #coveredByJacocoTestClasses type: #FAMIXMethod opposite: #coverJacocoMethods>
	<multivalued>
	<MSEComment: 'Methods whose tests cover this method'>
	^ self privateState
		attributeAt: #coveredByJacocoTestClasses
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coverJacocoMethods ]
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> coveredByTestClassesWithoutSomeClasses [

	^ self coveredByJacocoTestClasses reject: [ :c | c mooseName = 'net::atos::wlp::cedicam::AbstractTest' ]
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
FAMIXMethod >> isCoveredByJacocoTestClasses [
	<MSEProperty: #isCoveredByJacocoTestClasses type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment: 'If the method is covered by tests'>
	^ self coveredByJacocoTestClasses isNotEmpty
]

{ #category : #'*Jacoco-Import' }
FAMIXMethod >> isCoveringJacocoMethods [
	<MSEProperty: #isCoveringJacocoMethods type: #Boolean>
	<multivalued>
	<MSEComment: 'True is the class covers methods'>
	^ self coverJacocoMethods isNotEmpty
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isIgnored [
	<MSEProperty: #isIgnored type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment: 'If the method is a test'>
	^ self privateState
		attributeAt: #isIgnored
		ifAbsentPut: [ self annotationInstances contains: [ :instance | instance annotationType name = 'Ignore' ] ]
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
