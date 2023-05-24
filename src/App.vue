<template>
  <div id="app">
<!--    表单渲染器，预览、创建、编辑-->
    <avue-form v-if="formParser||formNew||formEdit" v-model="aVueValue" :option="aVueOptions"  @submit="handleSaveForm"/>
<!--    表单详情-->
    <div v-else-if="formDetail">
      <ul>
        <li v-for="item in aVueOptions.column" :key="item.prop">
          <label>{{item.label}}</label>
          <template v-if="item.props&&item.dicData">
            <!--            有数据字典-->
            <template v-if="Array.isArray(aVueValue[item.prop])">
              <!--            多选的数组-->
              <span v-for="propItem in aVueValue[item.prop]" :key="propItem">
                {{item.dicData.find((v)=>v[item.props.value]===propItem)[item.props.label]}}&nbsp;
              </span>
            </template>
            <template v-else>
              {{item.dicData.find((v)=>v[item.props.value]===aVueValue[item.prop])[item.props.label]}}
            </template>
          </template>
          <template v-else>
            {{aVueValue[item.prop]}}
          </template>
        </li>
      </ul>
    </div>
<!--    表单设计器-->
    <avue-form-design v-else :options="aVueOptions" @submit="handleSaveFormDesign"/>
  </div>
</template>

<script>
export default {
  name: 'app',
  data() {
    return {
      aVueMsg:{},
      aVueOptions: {
        submitBtn: false,
        emptyBtn: false,
      },
      aVueValue:{},
      formParser:window.location.href.includes('formParser'),
      formDetail:window.location.href.includes('formDetail'),
      formEdit:window.location.href.includes('formEdit'),
      formNew:window.location.href.includes('formNew'),
    }
  },
  computed:{
    typeText(){
      if(this.formParser){
        return '表单渲染器：预览'
      }else if(this.formNew){
        return '表单渲染器：创建'
      }else if(this.formEdit){
        return '表单渲染器：编辑'
      } else if(this.formDetail){
        return '表单详情'
      }else {
        return '表单设计器'
      }
    }
  },
  mounted(){
    console.log(`子iframe当前展示的是：${this.typeText}`,window.location.href)
    window.parent.postMessage({type: 'childStatus', data: 'isReady'}, '*')
    window.addEventListener('message', (e) => {
      if(e.data?.aVueOptions){
        console.log(`子iframe：${this.typeText}，接收到父页面传递过来的初始化数据`,e.data)
        this.aVueMsg=e.data
        this.aVueOptions = e.data?.aVueOptions
        if(this.typeText==='表单设计器'){
          this.aVueOptions.column.forEach((col)=>{
            const event=['change','click','focus','blur']
            const stringToFunc=(string)=>{
              if(string&&typeof string==='string'){
                return eval(string)
              }else {
                return string
              }
            }
            event.forEach((e)=>{
              col[e]=stringToFunc(col[e])
            })
          })
        }
      }
      if(e.data?.aVueValue){
        this.aVueValue=e.data?.aVueValue
      }
    });
  },
  watch: {
    aVueValue: {
      handler(val) {
        if(val && Object.keys(val).length>0 && this.aVueOptions.submitBtn === false){
          const msg={
            ...this.aVueMsg,
            aVueValue: val,
            aVueType:'New:v-model'
          }
          console.log(`子iframe：${this.typeText}，更新后实时向父页面传递数据`,msg)
          window.parent.postMessage(msg, '*');
        }
      },
      deep: true,
    },
  },
  methods: {
    handleSaveFormDesign(val) {
      const msg = {
        ...this.aVueMsg,
        aVueOptions: val,
        aVueType:'Design'
      }

      msg.aVueOptions.column.forEach((col)=>{
        const event=['change','click','focus','blur']
        const funcToString=(func)=>{
          if(func&&typeof func==='function'){
            return func.toString()
          }else {
            return func
          }
        }
        event.forEach((e)=>{
          col[e]=funcToString(col[e])
        })
      })
      console.log(`子iframe：${this.typeText}，点击保存向父页面传递数据`,msg)
      console.log(window)
      console.log(window.parent)
      window.parent.postMessage(msg, '*');
    },
    handleSaveForm(val,done) {
      done()
      const msg={
        ...this.aVueMsg,
        aVueValue: val,
        aVueType:'New:submit'
      }
      console.log(`子iframe：${this.typeText}，点击保存向父页面传递数据`,msg)
      window.parent.postMessage(msg, '*');
    },
  }
}
</script>
<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  min-height: 100%;
  height: 100%;
}
</style>
