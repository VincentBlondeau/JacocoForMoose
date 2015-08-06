Extension { #name : #FAMIXType }

{ #category : #'*Jacoco-Import' }
FAMIXType >> addInfinitestTests: aCollection [
	self shouldBeImplemented
]

{ #category : #'*Jacoco-Import' }
FAMIXType >> coverMethods [
	<MSEProperty: #coverMethods type: #FAMIXMethod opposite: #coveredByTestClasses>
	<multivalued>
	<MSEComment: 'Methods that are covered by this class'>
	^ self privateState
		attributeAt: #coverMethods
		ifAbsentPut: [ FMMultiMultivalueLink on: self opposite: #coveredByTestClasses ]
]

{ #category : #'*Jacoco-Import' }
FAMIXType >> coverMethods: aCollection [
	self coverMethods values: aCollection
]

{ #category : #'*Jacoco-Import' }
FAMIXType >> infinitestTests: aCollection [
	self privateState attributeAt: #infinitestTests put: aCollection
]

{ #category : #'*Jacoco-Import' }
FAMIXType >> isConsideredAsChangedByInfinitest [
	^ self privateState attributeAt: #isConsideredAsChangedByInfinitest ifAbsentPut: [ false ]
]

{ #category : #'*Jacoco-Import' }
FAMIXType >> isConsideredAsChangedByInfinitest: aBoolean [
	self privateState attributeAt: #isConsideredAsChangedByInfinitest put: aBoolean
]

{ #category : #'*Jacoco-Import' }
FAMIXType >> isCoveringMethods [
	<MSEProperty: #isCoveringMethods type: #Boolean>
	<multivalued>
	<MSEComment: 'True is the class covers methods'>
	^ self coverMethods isNotEmpty
]
