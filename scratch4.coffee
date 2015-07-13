hl7  = require('./src/hl7')

ORU_R01 = ['PID',
             ['PV1',
              ['PV2']],
             ['ORC',
               ['OBR',
                 ['NTE'],
                 ['OBX', ['NTE']]]]]

msg_str = """
MSH|^~\`|674|GHC|SISRL|PAML|20060922162830|L674-200609221628310220|ORU^R01|ORU000016168|P|2.3|||AL |AL
PID|||MRN12345^5^M11||APPLESEED^JOHN^A^III&Alias^Alias^A^||19710101|M||C|1 CATALYZE STREET^^MADISON^WI^53005-1020|GL|(414)379-1212|(414)271-3434||S||MRN12345001^2^M10|123456789|987654^NC|
PV1||E||E|||07369^DORIAN^ARMAND^H^^^MD^^^^^^^|||EMR||||||||E|visit-number|8814|5||||||||||||||||||001|OCCPD||||201101240700
ORC|RE|F4334|51013174200601|||||^||||||||||||||||
OBR|1|F4334|51013174200601|80048^BASIC METABOLIC PANEL|||20060922152300||||||||^^^^^|023901^PACLAB| ||||||^|CH|F|^^|^^^20060922162659^^GHA||^|||^^^^^^ ^^^^|^^^^^^^^^^|^^^^^^^^^^|^^^^^^^^^^||||||||||
OBX|1|NM|84295^SODIUM^GH|1|145|mmol/L|||||F|||20060922152300|GH
OBX|2|NM|84132^POTASSIUM^GH|2|5.2|mmol/L|||||F|||20060922152300|GH
OBX|3|NM|82435^CHLORIDE^GH|3|108|mmol/L|||||F|||20060922152300|GH
OBX|4|NM|82374^CARBON DIOXIDE^GH|4|31|mmol/L|||||F|||20060922152300|GH
OBX|5|NM|82947^GLUCOSE^GH|5|76|MG/DL|||||F|||20060922152300|GH
OBX|6|NM|84520^BUN^GH|6|22|MG/DL|||||F|||20060922152300|GH
OBX|7|NM|82565^CREATININE^GH^2160-0^CREATININE:MCNC:PT:SER/PLAS:QN:^LN|7|1.3|MG/DL|||||F|||20060922152300|GH
OBX|8|NM|82310^CALCIUM^GH|8|10.1|MG/DL|||||F|||20060922152300|GH
OBX|9|NM|GFR-AA*H^GFR--AFRICAN AMERICAN^GH|9|46|ML/MIN|||||F|||20060922152300|GH
OBX|10|NM|GFR*H^GFR--NON-AFRICAN AMERICAN^GH|10|46|ML/MIN|||||F|||20060922152300|GH
OBX|11|ST|84999.Z159||DNR||||||F||||GH
OBX|12|NM|84999.Z174^Anion Gap||6|mmol/L|||F
ORC|RE|F4334|51013174200601|||||^||||||||||||||||
OBR|1|F4334|51013174200601|80048^BASIC METABOLIC PANEL|||20060922152300||||||||^^^^^|023901^PACLAB| ||||||^|CH|F|^^|^^^20060922162659^^GHA||^|||^^^^^^ ^^^^|^^^^^^^^^^|^^^^^^^^^^|^^^^^^^^^^||||||||||
OBX|1|NM|84295^SODIUM^GH|1|145|mmol/L|||||F|||20060922152300|GH
OBX|2|NM|84132^POTASSIUM^GH|2|5.2|mmol/L|||||F|||20060922152300|GH
OBX|3|NM|82435^CHLORIDE^GH|3|108|mmol/L|||||F|||20060922152300|GH
OBX|4|NM|82374^CARBON DIOXIDE^GH|4|31|mmol/L|||||F|||20060922152300|GH
"""

msg = hl7.v2.parse(ORU_R01, msg_str)

res = hl7.fhir.bundle (bndl)->
  msg 'PID', (pid)->
    bndl.$entry 'Patient', (pt)->
      pt_id = 'temporal'
      pt.$el 'id', pt_id
      pid 5, (name)->
        pt.$el 'name', (nm)->
          name 1, (fname)->
            nm.$els 'family', fname
          name 2, (gname)->
            nm.$els 'given', gname
    pid 'PV1', (pv1)->
      console.log(' pv1')
    pid 'ORC', (orc)->
      bndl.$entry 'DiagnosticImaging', (dm)->
        orc 2, (order_id)->
          dm.$el 'identifier', order_id(1)
        orc 'OBR', (obr)->
          obr 'OBX', (obx)->
            bndl.$entry 'Observation', (obs)->
              obx 3, (obx_type)->
                obs.$el 'type', (tp)->
                  tp.$els 'coding', (cd)->
                    cd.$el 'code', obx_type(1)
                    cd.$el 'display', obx_type(2)

#console.log JSON.stringify(res)
p = (x)-> console.log(x)
