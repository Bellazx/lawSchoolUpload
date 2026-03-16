import request from '@/utils/request'

export function getStudents(params) {
  return request({
    url: '/students',
    method: 'get',
    params
  })
}

export function updateStudent(id, data) {
  return request({
    url: `/students/${id}`,
    method: 'put',
    data
  })
}

export function exportStudents(params) {
  return request({
    url: '/students/export',
    method: 'get',
    params
  })
}

export function triggerZ308Update(data) {
  return request({
    url: '/trigger/z308-update',
    method: 'post',
    data,
    timeout: 300000 // 5分钟超时，批量同步可能需要较长时间
  })
}

export function syncSingleStudentAleph(id) {
  return request({
    url: `/students/${id}/sync-aleph`,
    method: 'post',
    timeout: 30000 // 30秒超时，单条同步
  })
}

export function getUploadStatus() {
  return request({
    url: '/upload/status',
    method: 'get'
  })
}
