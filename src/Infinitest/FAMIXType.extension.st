Extension { #name : #FAMIXType }

{ #category : #'*Infinitest' }
FAMIXType >> coverInfinitestClasses [
	<MSEProperty: #coverInfinitestClasses type: #FAMIXClass opposite: #coveredByInfinitestTests>
	<multivalued>
	<MSEComment: 'Non Test classes that are covered by the test. The class must be a test to be not empty'>
	^ self privateState
		attributeAt: #coverInfinitestClasses
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coveredByInfinitestTests ]
]

{ #category : #'*Infinitest' }
FAMIXType >> coverInfinitestClasses: aCollection [
	self coverInfinitestClasses values: aCollection
]

{ #category : #'*Infinitest' }
FAMIXType >> coveredByInfinitestTests [
	<MSEProperty: #coveredByInfinitestTests type: #FAMIXClass opposite: #coverInfinitestClasses>
	<multivalued>
	<MSEComment: 'Test classes that cover this class'>
	^ self privateState
		attributeAt: #coveredByInfinitestTests
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coverInfinitestClasses ]

]

{ #category : #'*Infinitest' }
FAMIXType >> coveredByInfinitestTests: aCollection [
	self coveredByInfinitestTests value: aCollection
]

{ #category : #'*Infinitest' }
FAMIXType >> isConsideredAsChangedByInfinitest [
	<MSEProperty: #isConsideredAsChangedByInfinitest type: #Boolean>
	<MSEComment: 'True is chansidered as changed by infinitest'>
	^ self privateState attributeAt: #isConsideredAsChangedByInfinitest ifAbsentPut: [ false ]
]

{ #category : #'*Infinitest' }
FAMIXType >> isConsideredAsChangedByInfinitest: aBoolean [
	self privateState attributeAt: #isConsideredAsChangedByInfinitest put: aBoolean
]

{ #category : #'*Infinitest' }
FAMIXType >> testMethods [
	^ self privateState
		attributeAt: #testMethods
		ifAbsentPut: [ self methods select: [ :m | m isNotIgnoredTest ] ]
]
