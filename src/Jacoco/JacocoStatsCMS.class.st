Class {
	#name : #JacocoStatsCMS,
	#superclass : #JacocoStats,
	#category : #'Jacoco-TestSelection'
}

{ #category : #'as yet unclassified' }
JacocoStatsCMS >> isMethodAnchorInTheCoreDir: method [
	^ method sourceAnchor
				ifNil:
					[ method belongsTo sourceAnchor fileName
						beginsWith: './wlp-cms-core/src/main' ]
				ifNotNil:
					[ :sa | sa fileName beginsWith: './wlp-cms-core/src/main' ]
]

{ #category : #'as yet unclassified' }
JacocoStatsCMS >> isMethodAnchorInTheTestDir: method [
	^ method sourceAnchor
				ifNil:
					[ method belongsTo sourceAnchor fileName
						beginsWith: './wlp-cms-core/src/test' ]
				ifNotNil:
					[ :sa | sa fileName beginsWith: './wlp-cms-core/src/test' ]
]

{ #category : #accessing }
JacocoStatsCMS >> shouldRemoveSpecificly: element [
	^ element
		=
			self testGetterSetter
]

{ #category : #accessing }
JacocoStatsCMS >> testGetterSetter [
	^ testGetterSetter ifNil: [ testGetterSetter := self model testGetterSetter ]
]
