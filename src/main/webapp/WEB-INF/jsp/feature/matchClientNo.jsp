<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>물류실적 고객코드</title>


<script src="https://uicdn.toast.com/grid/latest/tui-grid.js"></script>
<link rel="stylesheet" href="https://uicdn.toast.com/grid/latest/tui-grid.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.1/xlsx.full.min.js"></script>


	<link rel="stylesheet" href="/resource/css/style.css" />


<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>

<script type="text/javascript">
window.onload = function(){
// 	document.getElementById('fExcel').addEventListener('change', readExcel);
	document.getElementById('fExcel').addEventListener('change', excelExport);
}
function readExcel(){
    let input = event.target;
    let reader = new FileReader();
    reader.onload = function () {
        let data = reader.result;
        let workBook = XLSX.read(data, { type: 'binary' });
        workBook.SheetNames.forEach(function (sheetName) {
            let rows = XLSX.utils.sheet_to_json(workBook.Sheets[sheetName]);
        })
    };
    reader.readAsBinaryString(input.files[0]);
	
}




function excelExport(event){
	state.init();
	excelExportCommon(event, handleExcelDataAll);
}
function excelExportCommon(event, callback){
    var input = event.target;
    var reader = new FileReader();
    reader.onload = function(){
        var fileData = reader.result;
        var wb = XLSX.read(fileData, {type : 'binary'});
        var sheetNameList = wb.SheetNames; // 시트 이름 목록 가져오기
        sheetNameList.forEach(function(sheetName){
	        var sheet = wb.Sheets[sheetName]; // 첫번째 시트 
	        callback(sheet, sheetName);      
        });
        state.feature();	//기능함수 호출
    	instance.resetData(state.resultInfo[0].data); //데이터출력
        
    };
    reader.readAsBinaryString(input.files[0]);
}
function handleExcelDataAll(sheet, sheetName){
	handleExcelDataHeader(sheet); // header 정보 
	handleExcelDataJson(sheet); // json 형태
	handleExcelDataCsv(sheet); // csv 형태
	handleExcelDataHtml(sheet); // html 형태
	handleExcelDataGrid(sheet, sheetName); // grid 형태
}
function handleExcelDataHeader(sheet){
    var headers = get_header_row(sheet);
    $("#displayHeaders").html(JSON.stringify(headers));
}
function handleExcelDataJson(sheet){
    $("#displayExcelJson").html(JSON.stringify(XLSX.utils.sheet_to_json (sheet)));
}
function handleExcelDataCsv(sheet){
    $("#displayExcelCsv").html(XLSX.utils.sheet_to_csv (sheet));
}
function handleExcelDataHtml(sheet){
    $("#displayExcelHtml").html(XLSX.utils.sheet_to_html (sheet));
}

var state = {
	init: function(){
		this.currentSheetIdx=0;
		resultInfo = [];
	},
	currentSheetIdx : 0,
	defColumn: [
		//첫번째 시트 컬럼 정의..
		{
			userCode: '고객코드',
			client: '고객'	
		}
		//두번째 시트 컬럼 정의..
		,{
			userCode: '고객코드',
			client: '거래처명',
			local: '지역',
			localGroup: '지역그룹',
			person: '담당자'
		}
	],
	resultInfo: [],
	feature: function(){
		var sheet1 = this.resultInfo[0].data;
		var sheet2 = this.resultInfo[1].data;
		
		sheet1.forEach(function(row){
			var i = 0;
			while(i<sheet2.length){
				i++;
				if(row.client === sheet2[i].client){
					row.userCode = sheet2[i].userCode;
					break;
				}
			}
		});
	}
}
function handleExcelDataGrid(sheet, sheetName){
	let mSheet = {
		sheetName: sheetName,
		title: '',
		col: state.defColumn[state.currentSheetIdx],
		data: []
	};
	state.currentSheetIdx++;

	//HeaderName..
	var headers = get_header_row(sheet);
	mSheet.title = getHeaderName(headers);
	
	//Header..
	const dataset = XLSX.utils.sheet_to_json(sheet);
	for(let col in dataset[0]){
		for(key in mSheet.col){
			if(mSheet.col[key]==dataset[0][col]){	//컬럼명칭이 일치하면...
				mSheet.col[key]=col;	//col 값으로 replace
				break;
			}
		}
	}
	
	
	//Body..
	for(let i=1; i<dataset.length; i++){
		let row = dataset[i];
		var data = {};
		for(let key in mSheet.col){
			data[key] = row[mSheet.col[key]];
		}		
		mSheet.data.push(data);
	}
	
	//Push Dataset..
	state.resultInfo.push(mSheet); 
	
	function getHeaderName(headers){
		headers.forEach(function(text, idx){
			headers[idx] = text.replace(/UNKNOWN+ [0-9]/gi,'');
		});
		return headers.join('').trim();
	}
	
}
// 출처 : https://github.com/SheetJS/js-xlsx/issues/214
function get_header_row(sheet) {
    var headers = [];
    var range = XLSX.utils.decode_range(sheet['!ref']);
    var C, R = range.s.r; /* start in the first row */
    /* walk every column in the range */
    for(C = range.s.c; C <= range.e.c; ++C) {
        var cell = sheet[XLSX.utils.encode_cell({c:C, r:R})] /* find the cell in the first row */

        var hdr = "UNKNOWN " + C; // <-- replace with your desired default 
        if(cell && cell.t) hdr = XLSX.utils.format_cell(cell);

        headers.push(hdr);
    }
    return headers;
}

</script>

<style type="text/css">
	div.content{
		margin: 10px;
	}
</style>

</head>
<body>
	<div class="app-container">
		<div class="app-item nav">
			<jsp:include page="../nav.jsp"></jsp:include>
		</div>

		<div class="app-item article">
			<h1>물류실적 고객코드 매칭</h1>
			<div class="content">
				<input type="file" id="fExcel" name="fExcel" />
				<details>
					<summary>메뉴 세부정보</summary>
					<ul>
						<li>`고객코드일치`시트의 고객명으로 `물류담당DB`시트에서 일치하는 고객의 고객번호를 찾아 출력한다.</li>
						<li>첨부파일은 2개의 시트(고객코드일치, 물류담당DB)가 있어야 한다.</li>
						<span>[고객코드일치] 시트</span>
						<ul>
							<li>1행: 제목.</li>
							<li>2행: 컬럼명. ex) A열:고객코드, B열:고객</li>
							<li>3~xxx행: 데이터</li>
						</ul>
						[물류담당DB] 시트
						<ul>
							<li>1행: 제목. ex) 2020/2021년도 고객현황</li>
							<li>2행: 컬럼명. ex) A열:고객코드, B열:거래처명</li>
							<li>3~xxx행: 데이터</li>
						</ul>
					</ul>
				</details>
		<!-- 		<h1>Header 정보 보기</h1> -->
		<!-- 		<div id="displayHeaders"></div> -->
		<!-- 		<h1>JSON 형태로 보기</h1> -->
		<!-- 		<div id="displayExcelJson"></div> -->
		<!-- 		<h1>CSV 형태로 보기</h1> -->
		<!-- 		<div id="displayExcelCsv"></div> -->
		<!-- 		<h1>HTML 형태로 보기</h1> -->
		<!-- 		<div id="displayExcelHtml"></div> -->
			</div>

			<div id="grid"></div>
		</div>
	</div>
</body>


<script type="text/javascript">
//import Grid from 'tui-grid'; /* ES6 */
const Grid = tui.Grid;

const instance = new Grid({
	el: document.getElementById('grid'), // Container element
	rowHeaders: ['rowNum'],
	bodyHeight: 450,
	columns: [
		{
			header: '고객코드',
			name: 'userCode',
			minWidth: 100,
			filter: 'select',
			sortingType: 'desc',
			sortable: true
		},
		{
			header: '고객',
			name: 'client',
			minWidth: 100,
			filter: 'select',
			sortingType: 'desc',
			sortable: true
		}
	]
});

// instance.resetData(newData); // Call API of instance's public method

Grid.applyTheme('striped'); // Call API of static method

</script>

</html>