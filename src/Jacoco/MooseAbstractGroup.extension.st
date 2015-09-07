Extension { #name : #MooseAbstractGroup }

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> allModelMethodsCoveredByJacocoTestCases [
	^ self methodsCoveredByJacocoTestCases reject: #isStub
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> averageNumberOfMethodCoveredByATest [
	| rejectBlock |
	rejectBlock := [ :e | e = self testGetterSetter or: [ e testIsGreen not ] ].
	^ ((((self allModelMethods reject: [ :e | e isStub ])
		select:
			[ :m | 
			(m sourceAnchor
				ifNil: [ m belongsTo sourceAnchor fileName beginsWith: './wlp-cms-core/src/test' ]
				ifNotNil: [ :sa | sa fileName beginsWith: './wlp-cms-core/src/test' ]) and: [ m isCoveringJacocoMethods ] ])
		reject: rejectBlock)
		average:
			[ :entity | 
			(entity coverJacocoMethods
				select:
					[ :m | 
					m isStub not
						and:
							[ 
							m sourceAnchor
								ifNil: [ m belongsTo sourceAnchor fileName beginsWith: './wlp-cms-core/src/main' ]
								ifNotNil: [ :sa | sa fileName beginsWith: './wlp-cms-core/src/main' ] ] ]) size ]) asFloat
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> averageNumberOfTestThatCoversAMethod [
	| rejectBlock |
	rejectBlock := [ :e | e = self testGetterSetter or: [ e testIsGreen not ] ].
	^ ((self testsThatPass) average: [ :entity | (entity coveredByJacocoTestMethods reject: rejectBlock) size ]) asFloat
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> methodsCoveredByJacocoTestCases [
]

{ #category : #'*Jacoco-Import tests' }
MooseAbstractGroup >> selectNotIgnoredTests [
	^ self select: [:m | m isNotIgnoredTest ] 
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> testGetterSetter [
	^ self
		entityNamed:
			'net::atos::wlp::cms::core::commons::CodeCoverageEnhancerTestCase.testGetterSetter()'
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> testsMethodsCoveringJacocoMethods [
	
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> testsThatPass [
	| rejectBlock |
	rejectBlock := [ :e | e = self testGetterSetter or: [ e testIsGreen not ] ].
	^ (self allModelMethods reject: [ :e | e isStub ])
		select:
			[ :m | 
			(m sourceAnchor ifNil: [ m belongsTo sourceAnchor fileName beginsWith: './wlp-cms-core/src/main' ] ifNotNil: [ :sa | sa fileName beginsWith: './wlp-cms-core/src/main' ])
				and: [ m isCoveredByJacocoTestMethodsByRejecting: rejectBlock ] ]
]
