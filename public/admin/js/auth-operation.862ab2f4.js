"use strict";(self["webpackChunkvue_cms_admin"]=self["webpackChunkvue_cms_admin"]||[]).push([[810],{1953:function(e,t,i){i.r(t),i.d(t,{default:function(){return p}});var o=function(){var e=this,t=e._self._c;return t("el-card",{staticClass:"table-card"},[t("div",{staticClass:"header",attrs:{slot:"header"},slot:"header"},[t("span",[e._v("路由管理")]),t("el-button",{attrs:{plain:"",type:"primary",icon:"el-icon-circle-plus-outline"},on:{click:function(t){e.insert_dialog_visible=!0}}},[e._v(" 添加操作按钮 ")])],1),t("el-table",{attrs:{data:e.tableData}},[t("el-table-column",{attrs:{prop:"operation_id",label:"#",width:"40"}}),t("el-table-column",{attrs:{prop:"operation_name",label:"操作名称"}}),t("el-table-column",{attrs:{prop:"operation_code",label:"操作代码"}}),t("el-table-column",{attrs:{prop:"operation_description",label:"操作描述"}}),t("el-table-column",{attrs:{label:"操作"},scopedSlots:e._u([{key:"default",fn:function(i){return[t("el-button",{attrs:{icon:"el-icon-edit",type:"primary",plain:""},on:{click:function(t){return e.openEditDialog(i.row)}}},[e._v("编辑")]),t("el-button",{attrs:{icon:"el-icon-delete",type:"danger",plain:""},on:{click:function(t){return e.handleRemove(i.row.operation_id,i.$index)}}},[e._v(" 删除 ")])]}}])})],1),t("el-dialog",{attrs:{title:"添加操作按钮",visible:e.insert_dialog_visible},on:{"update:visible":function(t){e.insert_dialog_visible=t},close:function(t){return e.handleDialogClose("insert_form")}}},[t("el-form",{ref:"insert_form",attrs:{model:e.insert_form,rules:e.rules,"label-width":"80px"}},[t("el-form-item",{attrs:{label:"操作名称",prop:"operation_name"}},[t("el-input",{attrs:{placeholder:"请输入操作按钮名称"},model:{value:e.insert_form.operation_name,callback:function(t){e.$set(e.insert_form,"operation_name",t)},expression:"insert_form.operation_name"}})],1),t("el-form-item",{attrs:{label:"操作代码",prop:"operation_code"}},[t("el-input",{attrs:{placeholder:"请输入英文的操作代码"},model:{value:e.insert_form.operation_code,callback:function(t){e.$set(e.insert_form,"operation_code",t)},expression:"insert_form.operation_code"}})],1),t("el-form-item",{attrs:{label:"操作描述",prop:"operation_description"}},[t("el-input",{attrs:{placeholder:"请输入操作按钮的说明文字"},model:{value:e.insert_form.operation_description,callback:function(t){e.$set(e.insert_form,"operation_description",t)},expression:"insert_form.operation_description"}})],1)],1),t("span",{staticClass:"dialog-footer",attrs:{slot:"footer"},slot:"footer"},[t("el-button",{on:{click:function(t){e.insert_dialog_visible=!1}}},[e._v("取 消")]),t("el-button",{attrs:{type:"primary"},on:{click:e.handleInsert}},[e._v("添 加")])],1)],1),t("el-dialog",{attrs:{title:"编辑操作按钮",visible:e.edit_dialog_visible},on:{"update:visible":function(t){e.edit_dialog_visible=t},close:function(t){return e.handleDialogClose("edit_form")}}},[t("el-form",{ref:"edit_form",attrs:{model:e.edit_form,rules:e.rules,"label-width":"80px"}},[t("el-form-item",{attrs:{label:"操作名称",prop:"operation_name"}},[t("el-input",{model:{value:e.edit_form.operation_name,callback:function(t){e.$set(e.edit_form,"operation_name",t)},expression:"edit_form.operation_name"}})],1),t("el-form-item",{attrs:{label:"操作代码",prop:"operation_code"}},[t("el-input",{model:{value:e.edit_form.operation_code,callback:function(t){e.$set(e.edit_form,"operation_code",t)},expression:"edit_form.operation_code"}})],1),t("el-form-item",{attrs:{label:"操作描述",prop:"operation_description"}},[t("el-input",{model:{value:e.edit_form.operation_description,callback:function(t){e.$set(e.edit_form,"operation_description",t)},expression:"edit_form.operation_description"}})],1)],1),t("span",{staticClass:"dialog-footer",attrs:{slot:"footer"},slot:"footer"},[t("el-button",{on:{click:function(t){e.edit_dialog_visible=!1}}},[e._v("取 消")]),t("el-button",{attrs:{type:"primary"},on:{click:e.handleEdit}},[e._v("保 存")])],1)],1)],1)},r=[],a=(i(7658),i(1803)),s={name:"Operation",data(){return{tableData:[],insert_dialog_visible:!1,edit_dialog_visible:!1,insert_form:{operation_name:"",operation_code:"",operation_description:""},edit_form:{operation_name:"",operation_code:"",operation_description:""},current_operation:"",rules:{operation_name:[{required:!0,message:"请输入操作按钮名称",trigger:"blur"}],operation_code:[{required:!0,message:"请输入英文的操作代码",trigger:"blur"}],operation_description:[{required:!0,message:"请输入操作按钮的说明文字",trigger:"blur"}]}}},created(){document.title="操作按钮管理",this.loadList()},methods:{async loadList(){let{status:e,data:t}=await a.OX.list({pagesize:30});e&&(this.tableData=t)},handleInsert(){this.$refs.insert_form.validate((async e=>{if(e){let{status:e,msg:t,data:i}=await a.OX.insert(this.insert_form);e?(this.tableData.push({...this.insert_form,...i}),this.insert_dialog_visible=!1,this.$message.success(t)):this.$message.error(t)}}))},openEditDialog(e){this.current_operation=e,this.edit_form={...e},this.edit_dialog_visible=!0},handleEdit(){this.$refs.edit_form.validate((async e=>{if(e){let{operation_id:e}=this.edit_form,{status:t,msg:i,data:o}=await a.OX.update(e,this.edit_form);t?(Object.assign(this.current_operation,this.edit_form),this.edit_dialog_visible=!1,this.$message.success(i)):this.$message.error(i)}}))},async handleRemove(e,t){this.$confirm("此操作将永久删除该操作按钮, 是否继续?",{type:"warning"}).then((async()=>{let{status:i,msg:o}=await a.OX.remove(e);i&&(this.tableData.splice(t,1),this.$message.success(o))})).catch((()=>{this.$message.info("取消成功")}))},handleDialogClose(e){this.$refs[e].resetFields()}}},n=s,l=i(1001),d=(0,l.Z)(n,o,r,!1,null,"71577f3d",null),p=d.exports}}]);
//# sourceMappingURL=auth-operation.862ab2f4.js.map