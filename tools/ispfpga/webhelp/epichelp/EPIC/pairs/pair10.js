var pairs =
{
"physical":{"design":1,"errors":1,"drc":1}
,"design":{"rule":1,"physical":1,"menu":1}
,"rule":{"check":1,"checks":1}
,"check":{"(drc)":1}
,"(drc)":{"physical":1,"series":1}
,"series":{"tests":1}
,"tests":{"discover":1}
,"discover":{"logical":1}
,"logical":{"physical":1}
,"errors":{"design":1}
,"drc":{"applied":1,"epic":1,"runs":1,"run":1,"written":1,"messages":1}
,"applied":{"epic":1}
,"epic":{"bitgen":1,"selecting":1}
,"bitgen":{"(the":1}
,"(the":{"bit":1}
,"bit":{"generation":1}
,"generation":{"program)":1}
,"program)":{"run":1}
,"run":{"drc":1,"transparent":1}
,"selecting":{"command":1}
,"command":{"actions":1}
,"actions":{"panel":1}
,"panel":{"design":1}
,"menu":{"drc":1}
,"runs":{"automatically":1}
,"automatically":{"whenever":1}
,"whenever":{"changes":1,"manual":1,"add":1}
,"changes":{"logic":1}
,"logic":{"block":1,"operate":1,"incomplete)":1}
,"block":{"view":1}
,"view":{"whenever":1}
,"manual":{"routing":1}
,"routing":{"whenever":1,"component":1,"logic":1}
,"add":{"pins":1}
,"pins":{"net":1}
,"net":{"instances":1}
,"instances":{"drc":1}
,"transparent":{"results":1}
,"results":{"drc":1}
,"written":{"tcl":1}
,"tcl":{"console":1}
,"console":{"drc":1}
,"messages":{"error":1,"(for":1}
,"error":{"messages":1}
,"(for":{"conditions":1}
,"conditions":{"routing":1}
,"component":{"logic":1}
,"operate":{"correctly)":1}
,"correctly)":{"warnings":1}
,"warnings":{"(for":1}
,"incomplete)":{"running":1}
,"running":{"design":1}
,"checks":{"(drc)":1}
}
;Search.control.loadWordPairs(pairs);