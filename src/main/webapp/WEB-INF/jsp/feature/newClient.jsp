<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>신규 업체</title>


<script src="https://uicdn.toast.com/grid/latest/tui-grid.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.17.1/xlsx.full.min.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui.pagination/v3.4.0/tui-pagination.js"></script>
<link rel="stylesheet" href="https://uicdn.toast.com/grid/latest/tui-grid.css" />

<link rel="stylesheet" href="/resource/css/style.css" />

<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script type="text/javascript" defer>
window.onload = function(){
// 	document.getElementById('fExcel').addEventListener('change', readExcel);
	document.getElementById('fExcel').addEventListener('change', excelExport);
	initTabs();
}
function initTabs(){
	$('ul.tabs li').click(function(){					//선택자를 통해 tabs 메뉴를 클릭 이벤트를 지정해줍니다.
		var tab_id = $(this).attr('data-tab');

		$('ul.tabs li').removeClass('current');			//선택 되있던 탭의 current css를 제거하고
		$('.tab-content').removeClass('current');

		$(this).addClass('current');					//선택된 탭에 current class를 삽입해줍니다.
		$("#" + tab_id).addClass('current');

		state.gridInstances.forEach((inst)=>{
			inst.refreshLayout();
		});
	})
}
function initGrid(){
	state.resultInfo.forEach(function(sheet, idx){
		let tabNum = idx+1;

		//Tab
		let tabEl = document.querySelector('.container > ul.tabs > li').cloneNode();
		tabEl.textContent = sheet.sheetName;
		tabEl.dataset.tab = 'tab-'+tabNum;
		tabEl.className = 'tab-link';

		//Content
		let contentEl = document.querySelector('.container > div#tab-1').cloneNode();
		contentEl.id = 'tab-'+tabNum;
		contentEl.className = 'tab-'+tabNum+' tab-content';
		let titleEl = document.createElement('h1');
		titleEl.textContent = sheet.title;
		contentEl.appendChild(titleEl);
		let gridEl = document.createElement('div');
		gridEl.id = 'grid-'+tabNum;
		contentEl.appendChild(gridEl);


		//Tabs Draw
		if(idx === 0){
			document.querySelectorAll('.container > ul.tabs > li').forEach((element)=>{
				document.querySelector('.container > ul.tabs').removeChild(element);
			});
			document.querySelectorAll('.container > div').forEach((element)=>{
				element.remove();
			});
			tabEl.classList.add('current');
			contentEl.classList.add('current');
		}
		document.querySelector('.container > ul.tabs').appendChild(tabEl);
		document.querySelector('.container').appendChild(contentEl);


		//GridData Draw
		let cpGridConf = Object.assign({}, gridConf);
		cpGridConf.el = document.getElementById('grid-'+tabNum);
		// console.log(cpGridConf, sheet.data);
		state.gridInstances[idx] = new Grid(cpGridConf);
		state.gridInstances[idx].resetData(sheet.data); // Call API of instance's public method

	});
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
		// console.log(state.resultInfo);
        state.feature();	//기능함수 호출
    	// instance.resetData(state.resultInfo[2].data); //데이터출력
		initGrid();	//데이터출력
		initTabs();	//Tabs 이벤트리스너 초기화

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
	gridInstances: [],
	currentSheetIdx : 0,
	defColumn: [
		//시트 컬럼 정의..
		{
			client: '고객',
			newClient: '고객',
		}
	],
	resultInfo: [],
	feature: function(){
		this.resultInfo.forEach(function(sheet){	//Sheets loop
			let i = 0;
			while(i < sheet.data.length){
				let row = sheet.data[i++];
				if(row.newClient == undefined || row.newClient == null || row.newClient == '')
					continue;

				//신규업체 유무 설정
				let j = 0;
				let isNew = true;
				while(j < sheet.data.length){
					// console.log(sheet.data[j].client, row.newClient, sheet.data[j].client === row.newClient);
					if(sheet.data[j++].client === row.newClient){	//전년도 업체 중 하나와 일치한다면..
						isNew = false;
						break;
					}
				}
				row.isNewClient = isNew?'Y':'N';
			}
		});
	}
}
function handleExcelDataGrid(sheet, sheetName){
	let mSheet = {
		sheetName: sheetName,
		title: '',
		col: state.defColumn[0],
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

	div.container{
		padding: 10px;
		background-color: aquamarine;
	}

	ul.tabs{
		margin: 0px;
		padding: 0px;
		list-style: none;
	}

	ul.tabs li{
		display: inline-block;
		background: #898989;
		color: white;
		padding: 10px 15px;
		cursor: pointer;
	}

	ul.tabs li.current{
		background: #e0e0e0;
		color: #222;
	}

	.tab-content{
		display: none;
		background: #e0e0e0;
		padding: 12px;
	}

	.tab-content.current{
		display: inherit;
	}
</style>

</head>
<body>

	<div class="app-container">
		<div class="app-item nav">
			<jsp:include page="../nav.jsp"></jsp:include>
		</div>

		<div class="app-item article">
			<h1>신규고객 유무</h1>
			<div class="content">
				<input type="file" id="fExcel" name="fExcel" />
				<details>
					<summary>메뉴 세부정보</summary>
					<ul>
						<li>전년도와 금년도 고객을 비교하여 금년도 `신규고객` 유무를 출력하는 메뉴.</li>
						<li>첨부파일의 각 시트는 `A열:전년도 고객명, B열:금년도 고객명`이 작성 되어 있어야 한다.</li>
						<ul>
							<li>1행: 제목. ex) 2020/2021년도 고객현황</li>
							<li>2행: 컬럼명. ex) A열:고객, B열:고객</li>
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

			<div id="grid" style="display: none"></div>




			<div class="container">
				<!-- 탭 메뉴 상단 시작 -->
				<ul class="tabs">
					<li class="tab-link current" data-tab="tab-1">Tabs</li>
				</ul>
				<!-- 탭 메뉴 상단 끝 -->
				<!-- 탭 메뉴 내용 시작 -->
				<div id="tab-1" class="tab-1 current">
					<h1></h1>
					<div id="grid-1"></div>
				</div>
				<!-- 탭 메뉴 내용 끝 -->
			</div>
		</div>
	</div>



</body>


<script type="text/javascript" defer>

const tabList = document.querySelectorAll('.tab_menu .list li');

for(var i = 0; i < tabList.length; i++){
	tabList[i].querySelector('.btn').addEventListener('click', function(e){
		e.preventDefault();
		for(var j = 0; j < tabList.length; j++){
			tabList[j].classList.remove('is_on');
		}
		this.parentNode.classList.add('is_on');
	});
}



//import Grid from 'tui-grid'; /* ES6 */
const Grid = tui.Grid;


const gridConf = {
	el: document.getElementById('grid-1'), // Container
	rowHeaders: ['rowNum'],
	bodyHeight: 450,
	// pageOptions: {
	// 	useClient: true,
	// 	perPage: 10
	// },
	data: {
		api: {
			readData : {}
			,createData: { url: '', method: 'POST'}
			,updateData: { url: '', method: 'PUT'}
			,modifyData: { url: '', method: 'PUT'}
			,deleteData: { url: '', method: 'DELETE'}
		},
		initialRequest: false // 디폴트 값은 true
	},
	columns: [

		{
			header: '전년도 고객',
			name: 'client',
			minWidth: 100,
			filter: 'select',
			sortingType: 'desc',
			sortable: true
		},
		{
			header: '금년도 고객',
			name: 'newClient',
			minWidth: 100,
			filter: 'select',
			sortingType: 'desc',
			sortable: true
		},
		{
			header: '신규 고객',
			name: 'isNewClient',
			minWidth: 100,
			filter: 'select',
			sortingType: 'desc',
			sortable: true
		}
	]
}
const instance = new Grid(gridConf);

// 	instance.resetData(newData); // Call API of instance's public method

	Grid.applyTheme('striped'); // Call API of static method

</script>

</html>