import React from 'react'
import SelectionCell from './SelectionCell'
import OptionSelector from './OptionSelector'

export default class TransactionTableRow extends React.Component {
  constructor (props) {
    super(props)
    this.onChangeCategory = this.onChangeCategory.bind(this)
    this.onChangeTemporaryCessation = this.onChangeTemporaryCessation.bind(this)
  }

  onChangeCategory (value) {
    this.props.onChangeCategory(this.props.row.id, value)
  }

  onChangeTemporaryCessation (value) {
    this.props.onChangeTemporaryCessation(this.props.row.id, value)
  }

  mapYN (value) {
    return (value === 'Y' || value === 'y') ? 1 : 0
  }

  buildCells () {
    const row = this.props.row
    const ynOptions = [
      {
        label: 'Y',
        value: '1'
      },
      { label: 'N',
        value: '0'
      }
    ]

    const cells = this.props.columns.map((c) => {
      const clz = 'align-middle' + (c.rightAlign === true ? ' text-right' : '')
      if (c.editable) {
        if (c.name === 'sroc_category') {
          const categories = this.props.categories
          return (
            <td key={c.name} className={clz}>
              <SelectionCell
                name={c.name}
                value={row[c.name]}
                options={categories}
                onChange={this.onChangeCategory}
              />
            </td>
          )
        } else if (c.name === 'temporary_cessation') {
          return (
            <td key={c.name} className={clz}>
              <OptionSelector
                className='form-control'
                selectedValue={this.mapYN(row[c.name])}
                options={ynOptions}
                name={c.name}
                onChange={this.onChangeTemporaryCessation}
              />
            </td>
          )
        } else {
          return ( <td key={c.name}>Unknown editable</td>)
        }
      } else {
        return (
          <td key={c.name} className={clz}>
            { row[c.name] }
          </td>
        )
      }
    })

    return cells
  }

  render () {
    const row = this.props.row

    return (
      <tr key={row.id}>
        { this.buildCells() }
      </tr>
    )
  }
}
