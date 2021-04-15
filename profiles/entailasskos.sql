PREFIX ogc: <http://www.opengis.net/def/metamodel/> 
	  prefix skos: <http://www.w3.org/2004/02/skos/core#> 
      PREFIX prof: <http://www.opengis.net/def/metamodel/profile/>
      
            INSERT { GRAPH ?skos_graph {
    ?this a skos:ConceptScheme .
    ?this rdfs:comment "This object provides the metadata view of an application schema. Definitions are organised as a SKOS ConceptScheme and can be accessed via the collection view property."@en . 
	?this a owl:Ontology .
	?this owl:imports <http://www.opengis.net/ont/geosparql> .
	?this skos:definition ?def .
	?topcollection a skos:Collection .
    ?topcollection rdfs:comment "This is the collection viewpoint of this application schema, consisting of sub-collections of feature types, properties and codelists defined by the application schema."@en .
    ?topcollection skos:inScheme ?this .
    ?ftcollection a skos:Collection .
    ?ftcollection rdfs:label "Feature Types" .
    ?ftcollection rdfs:comment "All feature types declared in this Application Schema." .
    ?ftcollection skos:inScheme ?this .
	?pcollection a skos:Collection .
    ?pcollection rdfs:label "Feature Properties" .
    ?pcollection rdfs:comment "All properties declared in this Application Schema." .
    ?pcollection skos:inScheme ?this .
	?clcollection a skos:Collection .
    ?clcollection rdfs:label "Code Lists" .
    ?clcollection rdfs:comment "All Code Lists declared in this Application Schema" .
    ?clcollection skos:inScheme ?this .
	?topcollection skos:member ?ftcollection .
	?topcollection skos:member ?pcollection .
    ?topcollection skos:member ?clcollection .
	?ftcollection skos:member ?class .
    ?pcollection skos:member ?classprop .	
    ?class a skos:Concept , ogc:FeatureType .
    ?class skos:inScheme ?this .
    ?class skos:prefLabel ?bestpreflabel .
	?class rdfs:label ?bestpreflabel .
    ?class skos:inScheme ?this .
    ?class skos:broader ?parent .
    ?this ogc:sourceGraph ?g .
    ?class ?skospred ?skosprop .
    ?class ogc:featureproperty ?classprop .
    ?classprop a skos:Concept , ogc:FeatureProperty .
    ?classprop skos:inScheme ?this .
	?classprop rdfs:label ?bestproplabel .
    ?classprop rdfs:range ?proptype .
    ?classprop ?propskospred ?propskosprop .
	 ?classprop rdfs:domain ?propdomain .
	 ?classprop rdfs:range ?proprange .
} }
WHERE {
    GRAPH ?this { ?this a owl:Ontology } .
	    OPTIONAL { ?this skos:definition ?def }   
    OPTIONAL { ?this ogc:sourceGraph ?sourceGraph . }
    BIND ( COALESCE(?sourceGraph,?this) as ?g )
		BIND (URI(CONCAT(str(?g), "/")) AS ?topcollection) .
	BIND (URI(CONCAT(str(?g), "/FeatureTypes/")) AS ?ftcollection) .
	BIND (URI(CONCAT(str(?g), "/Properties/")) AS ?pcollection) .
	BIND (URI(CONCAT(str(?g), "/CodeLists/")) AS ?clcollection) .
    GRAPH ?g {
        ?class a owl:Class .
        OPTIONAL {
            ?class rdfs:subClassOf ?parent . ?parent a owl:Class .
            OPTIONAL { ?parent rdfs:label ?parentlabel }.
        } .
        OPTIONAL { ?class ?skospred ?skosprop FILTER (STRSTARTS(str(?skospred),str(skos:))) }
        OPTIONAL { 
            ?class rdfs:subClassOf ?bn. 
            ?bn a owl:Restriction . 
            ?bn owl:onProperty ?classprop . 
            ?bn owl:allValuesFrom ?proptype .
        	OPTIONAL { ?classprop rdfs:label ?proplabel . }
            OPTIONAL {
                ?classprop skos:prefLabel ?proppreflabel .
            } .
            OPTIONAL {
                ?classprop rdfs:range ?proprange .
            } .
            OPTIONAL {
                ?classprop rdfs:domain ?propdomain .
            } .
        }
         OPTIONAL { ?class rdfs:label ?classlabel . }
        OPTIONAL {
            ?class skos:prefLabel ?preflabel .
        } .
		
    } .
	BIND (STRLEN(STR(?g)) +2  AS ?trim )
     BIND( SUBSTR(STR(?class),?trim ) as ?classname )
	 BIND( SUBSTR(STR(?classprop),?trim ) as ?propname )
    BIND (COALESCE(IF(bound(?preflabel), ?preflabel, (1 / 0)), IF(bound(?classlabel), ?classlabel, (1 / 0)), ?classname) AS ?bestpreflabel) .
	BIND (COALESCE(IF(bound(?proppreflabel), ?proppreflabel, (1 / 0)), IF(bound(?proplabel), ?proplabel, (1 / 0)), ?propname) AS ?bestproplabel) .
    BIND (URI(CONCAT(str(?this), "?_view=inferred")) AS ?skos_graph) .
}